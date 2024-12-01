import 'package:flutter/material.dart';
import 'package:grand_flow/screens/login/login_screen.dart';
import 'package:grand_flow/screens/home_screen.dart';
import 'package:grand_flow/screens/settings_screen.dart';
import 'package:grand_flow/screens/items/new_item_screen.dart';
import 'package:grand_flow/screens/items/edit_item_screen.dart';
import 'package:grand_flow/models/item_model.dart';

void main() {
  runApp(GrandFlow());
}

class GrandFlow extends StatefulWidget {
  @override
  _GrandFlowState createState() => _GrandFlowState();
}

class _GrandFlowState extends State<GrandFlow> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grand Flow',
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(userId: 0), // Pass the correct userId
        '/settings': (context) => SettingsScreen(
              toggleTheme: _toggleTheme,
              logout: () => _logout(context),
            ),
        '/new_task': (context) =>
            NewItemScreen(userId: 0), // Pass the correct userId
        '/edit_task': (context) => EditItemScreen(
              item: Item(
                userId: 0, // Pass the correct userId
                name: 'Sample Name', // Pass the correct name
                description:
                    'Sample Description', // Pass the correct description
                dueDateTime: DateTime.now(), // Pass the correct dueDateTime
                category: 'Sample Category', // Pass the correct category
                type: 'Sample Type', // Pass the correct type
              ),
            ),
      },
    );
  }
}
