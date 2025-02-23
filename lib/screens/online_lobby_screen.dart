import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/core/styled_button.dart';
import '../widgets/core/styled_text_field.dart';
import '../widgets/core/theme_switcher.dart';

class OnlineLobbyScreen extends StatefulWidget {
  @override
  _OnlineLobbyScreenState createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final _gameIdController = TextEditingController();
  String _errorMessage = '';

  Future<void> _createGame() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'User not authenticated.';
      });
      return;
    }

    final initialUltimateBoard = List.generate(
      3,
      (_) => List.generate(3, (_) => List.generate(9, (_) => '')),
    );
    final initialBigBoard =
        List.generate(3, (_) => List.generate(3, (_) => ''));

    try {
      final response = await supabase
          .from('games')
          .insert({
            'player_x': user.id,
            'player_o': null,
            'board_state': jsonEncode(initialUltimateBoard),
            'big_board_state': jsonEncode(initialBigBoard),
            'current_turn': 'X',
            'winner': '',
            'active_board_row': null,
            'active_board_col': null,
          })
          .select()
          .single();

      final gameId = response['id'] as String? ?? '';
      if (gameId.isEmpty) {
        setState(() {
          _errorMessage = 'Failed to retrieve game ID.';
        });
        return;
      }

      Navigator.pushNamed(
        context,
        '/game',
        arguments: {
          'isOnline': true,
          'gameId': gameId,
          'isCreator': true, // Pass isCreator flag
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating game: $e';
      });
    }
  }

  Future<void> _joinGame() async {
    final gameId = _gameIdController.text.trim();
    if (gameId.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a game ID.';
      });
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'User not authenticated.';
      });
      return;
    }

    try {
      final game =
          await supabase.from('games').select().eq('id', gameId).maybeSingle();

      if (game == null) {
        setState(() {
          _errorMessage = 'Game not found.';
        });
        return;
      }

      // Check if the user is already a player
      final isPlayerX = game['player_x'] == user.id;
      final isPlayerO = game['player_o'] == user.id;

      if (isPlayerX || isPlayerO) {
        // User is already in the game, allow them to rejoin
        Navigator.pushNamed(
          context,
          '/game',
          arguments: {
            'isOnline': true,
            'gameId': gameId,
            'isCreator': isPlayerX, // Set isCreator based on player role
          },
        );
        return;
      }

      // If user is not a player and player_o is null, join as player_o
      if (game['player_o'] == null) {
        await supabase.from('games').update({
          'player_o': user.id,
        }).eq('id', gameId);

        Navigator.pushNamed(
          context,
          '/game',
          arguments: {
            'isOnline': true,
            'gameId': gameId,
            'isCreator': false, // Joiner is not the creator
          },
        );
        return;
      }

      // If both slots are taken and user isn't a player, deny access
      setState(() {
        _errorMessage = 'Game is full and you are not a player.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error joining game: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Lobby'),
        actions: [ThemeSwitcher()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StyledButton(
              onPressed: _createGame,
              child: const Text('Create Game'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Or join an existing game:',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            StyledTextField(
              controller: _gameIdController,
              labelText: 'Enter Game ID',
            ),
            const SizedBox(height: 12),
            StyledButton(
              onPressed: _joinGame,
              child: const Text('Join Game'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
