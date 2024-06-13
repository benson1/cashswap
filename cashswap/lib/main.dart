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
