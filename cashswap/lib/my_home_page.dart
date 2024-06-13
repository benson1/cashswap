import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Map<String, dynamic>> items = [];
  List<String> currencyPairs = [];
  String selectedCurrencyPair = ''; // Default selected currency pair
  double selectedExchangeRateValue = 0.0; // Default selected exchange rate value

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://10.0.2.2:3000/exchanges'); // Use 10.0.2.2 for Android emulator

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          items = data.cast<Map<String, dynamic>>();

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

          // Set default exchange rate value based on selected pair
          updateSelectedExchangeRate();
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error appropriately, e.g., show an error message to the user
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

void updateSelectedExchangeRate() {
  if (selectedCurrencyPair.isNotEmpty) {
    String baseCurrency = selectedCurrencyPair.split('/')[0].trim().toLowerCase();
    String quoteCurrency = selectedCurrencyPair.split('/')[1].trim().toLowerCase();

    for (var item in items) {
      List<dynamic> exchangeRates = item['exchangeRates'];
      for (var rate in exchangeRates) {
        if ((rate['base_currency_name'] == baseCurrency && rate['quote_currency_name'] == quoteCurrency)) {
          setState(() {
            selectedExchangeRateValue = rate['baseRateValue'].toDouble();
          });
          return;
        }
      }
    }
  }
}


void filterItems(String selectedPair) {
  setState(() {
    selectedCurrencyPair = selectedPair;
    updateSelectedExchangeRate();
  });
}


  @override
  Widget build(BuildContext context) {
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

            // Logic to extract delivery time or other data from item
            // Example:
            // deliveryTime = item['delivery_time'];

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
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exchange Rate: ${selectedExchangeRateValue.toStringAsFixed(5)}', // Display exchange rate
                                style: Theme.of(context).textTheme.bodyText1, // Adjust style as needed
                              ),
                              Text(
                                'Title ${index + 1}',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              Text(
                                'Username ${item['userName']}',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              Text(
                                'Distance: ${(index + 1) * 10} km',
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
    );
  }
}
