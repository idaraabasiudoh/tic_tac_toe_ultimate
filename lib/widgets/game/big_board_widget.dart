import 'package:flutter/material.dart';
import 'small_board_widget.dart';

class BigBoardWidget extends StatelessWidget {
  final List<List<List<String>>> ultimateBoard;
  final List<List<String>> bigBoard;
  final int? activeBoardRow;
  final int? activeBoardCol;
  final String winner;
  final bool isOnline;
  final bool isMyTurn;
  final Function(int, int, int) onTap;

  const BigBoardWidget({
    required this.ultimateBoard,
    required this.bigBoard,
    required this.activeBoardRow,
    required this.activeBoardCol,
    required this.winner,
    required this.isOnline,
    required this.isMyTurn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(8),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(9, (index) {
        int bigRow = index ~/ 3;
        int bigCol = index % 3;
        bool isActive = activeBoardRow == null && activeBoardCol == null
            ? bigBoard[bigRow][bigCol].isEmpty
            : (bigRow == activeBoardRow &&
                bigCol == activeBoardCol &&
                bigBoard[bigRow][bigCol].isEmpty);
        return SmallBoardWidget(
          board: ultimateBoard[bigRow][bigCol],
          winner: bigBoard[bigRow][bigCol],
          isActive: isActive,
          isPlayable:
              isActive && (isOnline ? isMyTurn : true) && winner.isEmpty,
          onTap: (smallIndex) {
            if (isActive && (isOnline ? isMyTurn : true) && winner.isEmpty) {
              onTap(bigRow, bigCol, smallIndex);
            }
          },
        );
      }),
    );
  }
}
