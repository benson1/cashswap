import 'package:flutter/material.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'People Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
