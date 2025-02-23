import 'package:flutter/material.dart';
import 'cell_widget.dart';

class SmallBoardWidget extends StatelessWidget {
  final List<String> board;
  final String winner;
  final bool isActive;
  final bool isPlayable;
  final Function(int) onTap;

  const SmallBoardWidget({
    required this.board,
    required this.winner,
    required this.isActive,
    required this.isPlayable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (winner.isNotEmpty) {
      return Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(
              color: isActive ? Colors.yellow : Colors.grey,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              winner,
              style: TextStyle(
                fontSize: 60,
                color: winner == 'X' ? Colors.blue[400] : Colors.red[400],
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: winner == 'X' ? Colors.blue : Colors.red,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(
            color: isActive ? Colors.yellow : Colors.grey,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: List.generate(9, (index) {
            return CellWidget(
              value: board[index],
              onTap: isPlayable ? () => onTap(index) : () {},
            );
          }),
        ),
      ),
    );
  }
}
