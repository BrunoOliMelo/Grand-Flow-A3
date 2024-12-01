import 'package:flutter/material.dart';
import 'package:grand_flow/screens/login/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final VoidCallback logout;

  SettingsScreen({required this.toggleTheme, required this.logout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Tema'),
              trailing: IconButton(
                icon: Icon(Icons.brightness_6),
                onPressed: toggleTheme,
              ),
            ),
            ListTile(
              title: Text('Sair'),
              trailing: IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                  logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
