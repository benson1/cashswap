import 'package:flutter/material.dart';

class CashDeliveryPage extends StatelessWidget {
  const CashDeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Cash Delivery Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
