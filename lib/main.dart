import 'package:flutter/material.dart';
import 'menu_page.dart';
import 'game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '421',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const MenuPage());
          case '/game':
            final int numberOfPlayers = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => GamePage(numberOfPlayers: numberOfPlayers),
            );
          default:
            return MaterialPageRoute(builder: (context) => const MenuPage());
        }
      },
    );
  }
}
