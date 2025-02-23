import 'package:flutter/material.dart';
import '../widgets/core/styled_button.dart';
import '../widgets/core/theme_switcher.dart';

class GameModesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Game Mode'),
        actions: [ThemeSwitcher()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StyledButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/game',
                  arguments: {'isOnline': false},
                );
              },
              child: Text('Local Multiplayer'),
            ),
            SizedBox(height: 24),
            StyledButton(
              onPressed: () {
                Navigator.pushNamed(context, '/online_lobby');
              },
              child: Text('Online Multiplayer'),
            ),
          ],
        ),
      ),
    );
  }
}