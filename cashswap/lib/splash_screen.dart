import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change the background color if needed
      body: Center(
        child: Image.asset('assets/images/logo.jfif'),
      ),
    );
  }
}