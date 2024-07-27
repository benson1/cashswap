import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressLookup extends StatefulWidget {
  final Function(String) onAddressSelected;

  AddressLookup({required this.onAddressSelected});

  @override
  _AddressLookupState createState() => _AddressLookupState();
}

class _AddressLookupState extends State<AddressLookup> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _predictions = [];
  bool _isLoading = false;
  final String _apiKey = 'AIzaSyAdkqLN5L8YdeyQaItNnXQGqZno6Qcus-k'; // Replace with your actual API key

  void _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _predictions = data['predictions'];
        });
      } else {
        // Handle response errors
        print('Error: ${response.statusCode}');
        setState(() {
          _predictions = [];
        });
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Exception: $e');
      setState(() {
        _predictions = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPredictionSelected(String placeId) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['result']['formatted_address'];
        widget.onAddressSelected(address);
      } else {
        // Handle response errors
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Set a fixed height for the AddressLookup widget
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Address',
                suffixIcon: _isLoading
                    ? CircularProgressIndicator()
                    : Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _predictions.isNotEmpty
                ? ListView.builder(
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      final prediction = _predictions[index];
                      final description = prediction['description'];

                      return ListTile(
                        title: Text(description),
                        onTap: () => _onPredictionSelected(prediction['place_id']),
                      );
                    },
                  )
                : Center(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('No predictions'),
                  ),
          ),
        ],
      ),
    );
  }
}