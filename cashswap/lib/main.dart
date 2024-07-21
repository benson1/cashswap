import 'package:flutter/material.dart';
import 'cash_delivery_page.dart';
import 'my_home_page.dart';
import 'people_page.dart';
import 'login_register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          bodyText2: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          headline1: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          headline2: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          headline3: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          headline4: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          headline5: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          headline6: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          subtitle1: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          subtitle2: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          caption: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          button: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
          overline: TextStyle(fontFamily: 'VolkswagenSerialXbold'),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggedIn = false;

  void _showLoginRegisterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => LoginRegisterPage(onLogin: _handleLogin),
    );
  }

  void _handleLogin(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void _navigateToProfile() {
    // Handle navigation to the user's profile
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quick Money'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cash Delivery'),
              Tab(text: 'Cash Exchanges'),
              Tab(text: 'People'),
            ],
          ),
          actions: [
            if (_isLoggedIn)
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: _navigateToProfile,
              ),
          ],
        ),
        body: const TabBarView(
          children: [
            CashDeliveryPage(),
            MyHomePage(title: 'Exchanges'),
            PeoplePage(),
          ],
        ),
        floatingActionButton: !_isLoggedIn
            ? FloatingActionButton(
                onPressed: () => _showLoginRegisterModal(context),
                child: const Icon(Icons.login),
              )
            : null,
      ),
    );
  }
}
