import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_ultimate/widgets/core/styled_button.dart';
import '../widgets/core/theme_switcher.dart';
import '../widgets/game/big_board_widget.dart';
import '../utils/game_logic.dart';

class GameScreen extends StatefulWidget {
  final bool isOnline;
  final String? gameId;
  final bool isCreator;

  const GameScreen({
    super.key,
    this.isOnline = false,
    this.gameId,
    this.isCreator = false,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<List<String>>> ultimateBoard;
  late List<List<String>> bigBoard;
  late String currentPlayer;
  int? activeBoardRow;
  int? activeBoardCol;
  String winner = '';
  bool isWaiting = true;
  Stream<List<Map<String, dynamic>>>? gameStream;
  String? mySymbol;
  late bool creatorStatus;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    creatorStatus = widget.isCreator;

    if (widget.isOnline) {
      final supabase = Supabase.instance.client;
      gameStream = supabase
          .from('games')
          .stream(primaryKey: ['id'])
          .eq('id', widget.gameId!)
          .map((data) => data.cast<Map<String, dynamic>>());

      // Set up stream listener to update local state in real-time
      gameStream!.listen((data) {
        if (data.isNotEmpty) {
          _updateLocalStateFromGameData(data[0]);
        }
      });

      // Initial setup for mySymbol and creator status
      gameStream!.first.then((game) {
        if (game.isNotEmpty) {
          final gameData = game[0];
          final userId = supabase.auth.currentUser?.id;
          if (userId == gameData['player_x']) {
            setState(() {
              creatorStatus = true;
            });
          }
          if (creatorStatus && gameData['player_x'] != userId) {
            supabase
                .from('games')
                .update({
                  'player_x': userId,
                  'current_turn': 'X',
                })
                .eq('id', widget.gameId!)
                .then((_) {
                  print('Updated game to set creator as X');
                })
                .catchError((error) {
                  print('Error updating game: $error');
                });
          }
          setState(() {
            mySymbol = gameData['player_x'] == userId
                ? 'X'
                : gameData['player_o'] == userId
                    ? 'O'
                    : null;
          });
        }
      });

      // Optional: Periodic sync every second (uncomment if stream reliability is a concern)
      _syncTimer = Timer.periodic(Duration(seconds: 1), (_) {
        supabase
            .from('games')
            .select()
            .eq('id', widget.gameId!)
            .single()
            .then((game) {
          _updateLocalStateFromGameData(game);
        }).catchError((error) {
          print('Periodic sync error: $error');
        });
      });
    } else {
      ultimateBoard = List.generate(
          3, (_) => List.generate(3, (_) => List.generate(9, (_) => '')));
      bigBoard = List.generate(3, (_) => List.generate(3, (_) => ''));
      currentPlayer = 'X';
      activeBoardRow = null;
      activeBoardCol = null;
      winner = '';
      isWaiting = false;
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void _updateLocalStateFromGameData(Map<String, dynamic> game) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    setState(() {
      if (mySymbol == null) {
        mySymbol = game['player_x'] == userId
            ? 'X'
            : game['player_o'] == userId
                ? 'O'
                : null;
      }
      ultimateBoard = (jsonDecode(game['board_state']) as List)
          .map((bigRow) => (bigRow as List)
              .map((smallBoard) => (smallBoard as List).cast<String>())
              .toList())
          .toList();
      bigBoard = (jsonDecode(game['big_board_state']) as List)
          .map((row) => (row as List).cast<String>())
          .toList();
      currentPlayer = game['current_turn'];
      winner = game['winner'] ?? '';
      activeBoardRow = game['active_board_row'];
      activeBoardCol = game['active_board_col'];
      isWaiting = game['player_o'] == null;
    });
  }

  void makeMove(int bigRow, int bigCol, int smallIndex) {
    print('Attempting move at ($bigRow, $bigCol, $smallIndex)');
    if (widget.isOnline) {
      if (isWaiting || currentPlayer != mySymbol || mySymbol == null) {
        print(
            'Move blocked: isWaiting=$isWaiting, currentPlayer=$currentPlayer, mySymbol=$mySymbol');
        return;
      }

      // Perform move locally first
      var result = makeMoveLogic(
        ultimateBoard: ultimateBoard,
        bigBoard: bigBoard,
        currentPlayer: currentPlayer,
        winner: winner,
        activeBoardRow: activeBoardRow,
        activeBoardCol: activeBoardCol,
        bigRow: bigRow,
        bigCol: bigCol,
        smallIndex: smallIndex,
      );

      if (result == null) {
        print('Invalid move');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid move!')),
        );
        return;
      }

      // Optimistically update local state for immediate UI feedback
      setState(() {
        ultimateBoard = result['ultimateBoard'];
        bigBoard = result['bigBoard'];
        currentPlayer = result['currentPlayer'];
        winner = result['winner'];
        activeBoardRow = result['activeBoard']?['row'];
        activeBoardCol = result['activeBoard']?['col'];
      });

      // Update backend
      Supabase.instance.client
          .from('games')
          .update({
            'board_state': jsonEncode(result['ultimateBoard']),
            'big_board_state': jsonEncode(result['bigBoard']),
            'current_turn': result['currentPlayer'],
            'winner': result['winner'],
            'active_board_row': result['activeBoard']?['row'],
            'active_board_col': result['activeBoard']?['col'],
          })
          .eq('id', widget.gameId!)
          .then((_) {
            print('Move successfully updated');
          })
          .catchError((error) {
            print('Error updating move: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating move: $error')),
            );
            // Optionally revert local state here if critical
          });
    } else {
      setState(() {
        var result = makeMoveLogic(
          ultimateBoard: ultimateBoard,
          bigBoard: bigBoard,
          currentPlayer: currentPlayer,
          winner: winner,
          activeBoardRow: activeBoardRow,
          activeBoardCol: activeBoardCol,
          bigRow: bigRow,
          bigCol: bigCol,
          smallIndex: smallIndex,
        );
        if (result != null) {
          ultimateBoard = result['ultimateBoard'];
          bigBoard = result['bigBoard'];
          currentPlayer = result['currentPlayer'];
          winner = result['winner'];
          activeBoardRow = result['activeBoard']?['row'];
          activeBoardCol = result['activeBoard']?['col'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid move!')),
          );
        }
      });
    }
  }

  void resetGame() {
    setState(() {
      ultimateBoard = List.generate(
          3, (_) => List.generate(3, (_) => List.generate(9, (_) => '')));
      bigBoard = List.generate(3, (_) => List.generate(3, (_) => ''));
      currentPlayer = 'X';
      activeBoardRow = null;
      activeBoardCol = null;
      winner = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOnline) {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: gameStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Ultimate Tic-Tac-Toe (Online)'),
                actions: [ThemeSwitcher()],
              ),
              body: const Center(
                child: Text(
                  'Game not found or deleted.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          // Use local state, which is kept in sync by the stream listener
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ultimate Tic-Tac-Toe (Online)'),
              actions: [ThemeSwitcher()],
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                if (isWaiting)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Waiting for opponent to join... (Game ID: ${widget.gameId})',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                Expanded(
                  child: BigBoardWidget(
                    ultimateBoard: ultimateBoard,
                    bigBoard: bigBoard,
                    activeBoardRow: activeBoardRow,
                    activeBoardCol: activeBoardCol,
                    winner: winner,
                    isOnline: widget.isOnline,
                    isMyTurn: !isWaiting && mySymbol == currentPlayer,
                    onTap: makeMove,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: StyledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Leave Game'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ultimate Tic-Tac-Toe (Local)'),
          actions: [ThemeSwitcher()],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      winner.isNotEmpty ? Colors.green[800] : Colors.blue[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  winner.isNotEmpty
                      ? 'Winner: $winner!'
                      : 'Player $currentPlayer\'s Turn',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BigBoardWidget(
                ultimateBoard: ultimateBoard,
                bigBoard: bigBoard,
                activeBoardRow: activeBoardRow,
                activeBoardCol: activeBoardCol,
                winner: winner,
                isOnline: false,
                isMyTurn: true,
                onTap: makeMove,
              ),
            ),
            if (winner.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: StyledButton(
                  onPressed: resetGame,
                  child: const Text('Reset Game'),
                ),
              ),
          ],
        ),
      );
    }
  }
}
