import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this import
import 'providers/theme_notifier.dart';
import 'screens/auth_wrapper.dart';
import 'screens/online_lobby_screen.dart';
import 'screens/game_screen.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with values from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ??
        'default_url_if_not_found', // Fallback value
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ??
        'default_key_if_not_found', // Fallback value
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Ultimate Tic-Tac-Toe',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeNotifier.themeMode,
            home: AuthWrapper(),
            routes: {
              '/online_lobby': (context) => OnlineLobbyScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/game') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => GameScreen(
                    isOnline: args['isOnline'],
                    gameId: args['gameId'],
                    isCreator: args['isCreator'] ?? false,
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
