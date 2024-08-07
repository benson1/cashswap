import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, this.mockData}) : super(key: key);

  final String title;
  final List<Map<String, dynamic>>? mockData;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Map<String, dynamic>> items = [];
  List<String> currencyPairs = [];
  String selectedCurrencyPair = ''; // Default selected currency pair

  // Dictionary mapping currency codes to their symbols
  final Map<String, String> currencySymbols = {
    'usd': '\$', // Dollar
    'eur': '€', // Euro
    'gbp': '£', // British Pound
    'jpy': '¥', // Japanese Yen
    'vnd': '₫', // Vietnamese Dong
    // Add more currency symbols as needed
  };

  TextEditingController amountController = TextEditingController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition(); // Get user's current position
    if (widget.mockData != null) {
      // Use mock data if provided
      items = widget.mockData!;
      processItems();
    } else {
      // Fetch data from API
      fetchData();
    }
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://10.0.2.2:3000/exchanges'); // Example API endpoint

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            items = data.cast<Map<String, dynamic>>();
            processItems();
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch data. Please check your connection.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          print('Current position: $_currentPosition');
          processItems(); // Process items again with current position
        });
      }
    } catch (e) {
      print('Error obtaining current position: $e');
    }
  }

  void processItems() {
    // Extract unique currency pairs from items
    Set<String> pairs = Set();
    for (var item in items) {
      List<dynamic> exchangeRates = item['exchangeRates'];
      for (var rate in exchangeRates) {
        pairs.add('${rate['base_currency_name']}/${rate['quote_currency_name']}');
        pairs.add('${rate['quote_currency_name']}/${rate['base_currency_name']}');
      }
    }
    currencyPairs = pairs.toList();
    selectedCurrencyPair = currencyPairs.isNotEmpty ? currencyPairs[0] : '';

    // Calculate and store exchange rates for all items
    updateSelectedExchangeRate();

    // Calculate distances for all items
    if (_currentPosition != null) {
      calculateDistances();
    }
  }

  void updateSelectedExchangeRate() {
    if (selectedCurrencyPair.isNotEmpty) {
      String baseCurrency = selectedCurrencyPair.split('/')[0].trim().toLowerCase();
      String quoteCurrency = selectedCurrencyPair.split('/')[1].trim().toLowerCase();

      for (var item in items) {
        List<dynamic> exchangeRates = item['exchangeRates'];
        for (var rate in exchangeRates) {
          if (rate['base_currency_name'] == baseCurrency && rate['quote_currency_name'] == quoteCurrency) {
            double baseRateValue = rate['baseRateValue'].toDouble();
            double commissionPercentage = rate['commissionPercentage'].toDouble();
            double commissionFlat = rate['commissionFlat'].toDouble();

            // Calculate amount after deducting commission
            double amountAfterCommission = calculateAmountAfterCommission(baseRateValue, commissionPercentage, commissionFlat);

            // Store calculated value in the item
            item['selectedExchangeRateValue'] = amountAfterCommission;
          }
        }
      }
      // Update the state to reflect changes
      if (mounted) {
        setState(() {});
      }
    }
  }

  void calculateDistances() {
    if (_currentPosition == null) {
      print('Current position is null, cannot calculate distances.');
      return;
    }

    for (var item in items) {
      if (item.containsKey('lattitude') && item.containsKey('longitude')) {
        double itemLatitude = item['lattitude'];
        double itemLongitude = item['longitude'];

        double distanceInMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          itemLatitude,
          itemLongitude,
        );

        // Convert distance to kilometers
        double distanceInKm = distanceInMeters / 1000;

        // Store distance in the item
        item['distance'] = distanceInKm;
        print('Calculated distance for item: ${item['userName']} is $distanceInKm km');
      } else {
        print('Item does not have latitude and longitude: ${item['userName']}');
      }
    }

    // Update the state to reflect changes
    if (mounted) {
      setState(() {});
    }
  }

  void filterItems(String selectedPair) {
    if (mounted) {
      setState(() {
        selectedCurrencyPair = selectedPair;
        updateSelectedExchangeRate();
      });
    }
  }

  String formatExchangeRate(double rate, String currency) {
    String symbol = currencySymbols[currency.toLowerCase()] ?? '';

    // Format the rate to 2 decimal places for USD, EUR, GBP, JPY
    if (currency.toLowerCase() != 'vnd') {
      return '$symbol${rate.toStringAsFixed(2)}';
    } else {
      // For VND, format to remove trailing zeros
      String rateString = rate.toStringAsFixed(5);
      rateString = rateString.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      return '$symbol$rateString';
    }
  }

  double calculateDisplayExchangeRate(double baseAmount, double baseRate, double commissionPercentage, double commissionFlat) {
    double amountAfterCommission = baseAmount * baseRate;
    amountAfterCommission = calculateAmountAfterCommission(amountAfterCommission, commissionPercentage, commissionFlat);
    return amountAfterCommission;
  }

  String getCurrencySymbol() {
    if (selectedCurrencyPair.isNotEmpty) {
      String baseCurrency = selectedCurrencyPair.split('/')[0].trim().toLowerCase();
      return currencySymbols[baseCurrency] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    String baseCurrency = '';
    String quoteCurrency = '';
    double displayExchangeRateValue = 0.0;

    // Extract base and quote currencies from selected pair
    if (selectedCurrencyPair.isNotEmpty) {
      baseCurrency = selectedCurrencyPair.split('/')[0].trim().toUpperCase();
      quoteCurrency = selectedCurrencyPair.split('/')[1].trim().toUpperCase();
    }

    // Parse the amount entered by the user
    double baseAmount = amountController.text.isEmpty ? (baseCurrency == 'VND' ? 100000 : 1) : double.parse(amountController.text.replaceAll(RegExp(r'[^\d.]'), ''));

    // Calculate the display exchange rate value
    if (selectedCurrencyPair.isNotEmpty) {
      String baseCurrency = selectedCurrencyPair.split('/')[0].trim().toLowerCase();
      String quoteCurrency = selectedCurrencyPair.split('/')[1].trim().toLowerCase();

      for (var item in items) {
        List<dynamic> exchangeRates = item['exchangeRates'];
        for (var rate in exchangeRates) {
          if (rate['base_currency_name'] == baseCurrency && rate['quote_currency_name'] == quoteCurrency) {
            double baseRateValue = rate['baseRateValue'].toDouble();
            double commissionPercentage = rate['commissionPercentage'].toDouble();
            double commissionFlat = rate['commissionFlat'].toDouble();

            displayExchangeRateValue = calculateDisplayExchangeRate(baseAmount, baseRateValue, commissionPercentage, commissionFlat);
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            const SizedBox(width: 20),
            DropdownButton<String>(
              value: selectedCurrencyPair,
              onChanged: (newValue) {
                filterItems(newValue!);
              },
              items: currencyPairs.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true), // Allows decimal input
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')), // Allow only numbers, dot, and comma
              ],
              decoration: InputDecoration(
                prefixText: getCurrencySymbol(), // Prepend currency symbol
                hintText: 'Enter amount',
              ),
              onChanged: (value) {
                setState(() {
                  // Trigger recalculation when the amount changes
                  // (although the calculation should ideally be in a separate function)
                  displayExchangeRateValue = calculateDisplayExchangeRate(baseAmount, 1.0, 0.0, 0.0);
                });
              },
            ),
            const SizedBox(height: 16), // Space between TextField and GridView
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // One item per row
                  childAspectRatio: 2, // Adjust the height of the grid items
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> item = items[index];
                  String deliveryTime = 'Unknown';
                  double selectedRate = 0.0;
                  // double distance = item.containsKey('distance') ? item['distance'] : 0.0;
                  double distance = 0.0;

                  if (item.containsKey('selectedExchangeRateValue')) {
                    selectedRate = item['selectedExchangeRateValue'];
                  }

                  // Calculate the display exchange rate value for each item
                  double displayRateForItem = calculateDisplayExchangeRate(baseAmount, selectedRate, 0.0, 0.0);

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                item['ImageURL'],
                                height: 50,
                                width: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.broken_image, size: 50); // Fallback image
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['userName'],
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                                        color: Colors.lightBlue,
                                      ), // Username with light blue color
                                    ),
                                    Text(
                                      'Exchange Rate: ${selectedRate.toStringAsFixed(10)}', // Display raw exchange rate
                                      style: Theme.of(context).textTheme.bodyText1, // Adjust style as needed
                                    ),
                                    Text(
                                      '$baseAmount $baseCurrency gets you ${formatExchangeRate(displayRateForItem, quoteCurrency.toLowerCase())}',
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                                        color: Color.fromARGB(255, 22, 56, 168),
                                      ), // Adjust style as needed
                                    ),
                                    Text(
                                      'Distance: ${distance.toStringAsFixed(2)} km',
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Button'),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.deepPurple.withOpacity(0.1),
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Est. delivery time: $deliveryTime',
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                                color: Colors.deepPurple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double calculateAmountAfterCommission(double baseAmount, double commissionPercentage, double commissionFlat) {
  return baseAmount * (1 - commissionPercentage / 100) - commissionFlat;
}

double calculateDisplayExchangeRate(double baseAmount, double baseRate, double commissionPercentage, double commissionFlat) {
  double amountAfterCommission = baseAmount * baseRate;
  amountAfterCommission = calculateAmountAfterCommission(amountAfterCommission, commissionPercentage, commissionFlat);
  return amountAfterCommission;
}

void main() {
  runApp(const MaterialApp(
    title: 'Flutter Demo',
    home: MyHomePage(title: 'Exchange Rates'),
  ));
}
