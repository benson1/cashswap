import 'dart:convert';
import 'package:cashswap/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart'; // Import for MockClient
import 'package:cashswap/main.dart'; // Adjust import to match your project structure

void main() {
  testWidgets('Verify exchange rate update', (WidgetTester tester) async {
    // Define mock data for testing
    final List<Map<String, dynamic>> mockData = [
      {
        'exchangeRates': [
          {
            'base_currency_name': 'usd',
            'quote_currency_name': 'vnd',
            'baseRateValue': 0.002,
            'commissionPercentage': 10.0,
            'commissionFlat': 0.0,
          },
        ],
        'ImageURL': 'https://example.com/image.png',
        'userName': 'Test User',
      },
    ];

    // Create a mock HTTP client to return the mock data
    final client = MockClient((request) async {
      return http.Response(jsonEncode(mockData), 200);
    });

    // Build the widget with MaterialApp
    await tester.pumpWidget(MaterialApp(
      home: MyHomePage(
        title: 'Exchange Rates',
        mockData: mockData, // Pass mockData to the widget
      ),
    ));

    // Wait for the data to be loaded (you might need to adjust the delay if necessary)
    await tester.pump(Duration(seconds: 1));

    // Verify that the exchange rate value is updated correctly
    expect(find.text('Exchange Rate: 0.001800'), findsOneWidget);

    // Optionally, you can further test interactions or other widget behaviors
  });
}
