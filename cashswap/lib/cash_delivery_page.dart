import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class CashDeliveryPage extends StatefulWidget {
  const CashDeliveryPage({super.key});

  @override
  _CashDeliveryPageState createState() => _CashDeliveryPageState();
}

class _CashDeliveryPageState extends State<CashDeliveryPage> {
  final TextEditingController _payController = TextEditingController();
  String _payCurrency = 'USD';
  String _receiveCurrency = 'EUR';
  String _paymentMethod = 'Visa/Mastercard';
  double _receiveAmount = 0.0;
  List<dynamic> exchanges = [];
  bool hasExchanges = true;
  List<String> availableCurrencies = ['USD', 'EUR', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    _fetchLocationAndExchanges();
  }

  Future<void> _fetchLocationAndExchanges() async {
    Position position;
    try {
      position = await _determinePosition();
    } catch (e) {
      setState(() {
        hasExchanges = false;
      });
      return;
    }

    //final url = 'http://10.0.2.2:3000/exchanges?longitude=${position.longitude}&latitude=${position.latitude}';
    final url = 'http://10.0.2.2:3000/exchanges?longitude=98.984400&latitude=18.789660';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        if (data.isEmpty) {
          hasExchanges = false;
        } else {
          exchanges = data;
          _payCurrency = exchanges[0]['exchangeRates'][0]['base_currency_name'].toUpperCase();
          _receiveCurrency = exchanges[0]['exchangeRates'][0]['quote_currency_name'].toUpperCase();
          availableCurrencies = _getAvailableCurrencies();
        }
      });
    } else {
      setState(() {
        hasExchanges = false;
      });
    }
  }

  List<String> _getAvailableCurrencies() {
    Set<String> currencies = {};
    for (var exchange in exchanges) {
      for (var rate in exchange['exchangeRates']) {
        currencies.add(rate['base_currency_name'].toUpperCase());
        currencies.add(rate['quote_currency_name'].toUpperCase());
      }
    }
    return currencies.toList();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void _calculateReceiveAmount() {
    final double payAmount = double.tryParse(_payController.text) ?? 0.0;
    setState(() {
      _receiveAmount = payAmount * 0.96;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cash Delivery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasExchanges
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _payController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'You Pay',
                            prefixText: _payCurrency + ' ',
                          ),
                          onChanged: (value) {
                            _calculateReceiveAmount();
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: availableCurrencies.contains(_payCurrency) ? _payCurrency : null,
                        items: availableCurrencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _payCurrency = newValue!;
                            _calculateReceiveAmount();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    items: <String>['Visa/Mastercard', 'Google Pay', 'Apple Pay'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _paymentMethod = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            'You Receive: ${_receiveAmount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: availableCurrencies.contains(_receiveCurrency) ? _receiveCurrency : null,
                        items: availableCurrencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _receiveCurrency = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )
            : Center(
                child: Text('No exchanges available for your location'),
              ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CashDeliveryPage(),
  ));
}
