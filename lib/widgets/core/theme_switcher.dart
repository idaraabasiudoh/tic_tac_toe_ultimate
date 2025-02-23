import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_notifier.dart';

class ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return IconButton(
      icon: Icon(
        themeNotifier.themeMode == ThemeMode.light
            ? Icons.dark_mode
            : Icons.light_mode,
      ),
      onPressed: () {
        themeNotifier.toggleTheme();
      },
    );
  }
}