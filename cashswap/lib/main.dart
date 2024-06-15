import 'package:flutter/material.dart';
import 'my_home_page.dart';
import 'people_page.dart';

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
        textTheme: TextTheme(
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Exchanges'),
              Tab(text: 'People'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyHomePage(title: 'Exchanges'),
            PeoplePage(),
          ],
        ),
      ),
    );
  }
}
