//import 'dart:convert';

Map<String, dynamic>? makeMoveLogic({
  required List<List<List<String>>> ultimateBoard,
  required List<List<String>> bigBoard,
  required String currentPlayer,
  required String winner,
  required int? activeBoardRow,
  required int? activeBoardCol,
  required int bigRow,
  required int bigCol,
  required int smallIndex,
}) {
  if (winner.isNotEmpty) return null;

  if (activeBoardRow != null && activeBoardCol != null) {
    if (bigRow != activeBoardRow || bigCol != activeBoardCol) return null;
  }

  if (bigBoard[bigRow][bigCol].isNotEmpty) return null;

  int smallRow = smallIndex ~/ 3;
  int smallCol = smallIndex % 3;
  if (ultimateBoard[bigRow][bigCol][smallIndex].isNotEmpty) return null;

  // Deep copy to avoid modifying the original until confirmed
  List<List<List<String>>> newUltimateBoard = ultimateBoard
      .map((big) => big.map((small) => List<String>.from(small)).toList())
      .toList();
  newUltimateBoard[bigRow][bigCol][smallIndex] = currentPlayer;

  List<List<String>> newBigBoard =
      bigBoard.map((row) => List<String>.from(row)).toList();
  List<String> smallBoard = newUltimateBoard[bigRow][bigCol];
  String smallWinner = checkSmallBoardWinner(smallBoard);
  if (smallWinner.isNotEmpty) {
    newBigBoard[bigRow][bigCol] = smallWinner;
  }

  String bigWinner = checkBigBoardWinner(newBigBoard);
  String newWinner = bigWinner;

  int nextBigRow = smallRow;
  int nextBigCol = smallCol;
  Map<String, int>? nextActiveBoard;
  if (newBigBoard[nextBigRow][nextBigCol].isNotEmpty ||
      newUltimateBoard[nextBigRow][nextBigCol]
          .every((cell) => cell.isNotEmpty)) {
    nextActiveBoard = null;
  } else {
    nextActiveBoard = {'row': nextBigRow, 'col': nextBigCol};
  }

  String nextPlayer = currentPlayer == 'X' ? 'O' : 'X';

  return {
    'ultimateBoard': newUltimateBoard,
    'bigBoard': newBigBoard,
    'currentPlayer': nextPlayer,
    'winner': newWinner,
    'activeBoard': nextActiveBoard,
  };
}

String checkSmallBoardWinner(List<String> board) {
  const List<List<int>> winConditions = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8], // Rows
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8], // Columns
    [0, 4, 8],
    [2, 4, 6] // Diagonals
  ];
  for (var condition in winConditions) {
    if (board[condition[0]].isNotEmpty &&
        board[condition[0]] == board[condition[1]] &&
        board[condition[1]] == board[condition[2]]) {
      return board[condition[0]];
    }
  }
  return '';
}

String checkBigBoardWinner(List<List<String>> board) {
  const List<List<int>> winConditions = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8], // Rows
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8], // Columns
    [0, 4, 8],
    [2, 4, 6] // Diagonals
  ];
  for (var condition in winConditions) {
    int r1 = condition[0] ~/ 3, c1 = condition[0] % 3;
    int r2 = condition[1] ~/ 3, c2 = condition[1] % 3;
    int r3 = condition[2] ~/ 3, c3 = condition[2] % 3;
    if (board[r1][c1].isNotEmpty &&
        board[r1][c1] == board[r2][c2] &&
        board[r2][c2] == board[r3][c3]) {
      return board[r1][c1];
    }
  }
  return '';
}
