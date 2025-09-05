import 'package:flutter/material.dart';
import '../models/mark.dart';
import '../painters/board_painter.dart';
import '../widgets/tool_buttons.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class OXBoard extends StatefulWidget {
  const OXBoard({super.key});

  @override
  State<OXBoard> createState() => _OXBoardState();
}

class _OXBoardState extends State<OXBoard> {
  List<Mark> _marks = <Mark>[];
  String _selectedTool = 'square'; // starting tool
  bool _isGameOver = false;
  String? _winnerType;

  static const double _markSize = 400.0/_gridSize;
  static const int _gridSize = 5; // Define grid size consistently
  static const String _emptyCell = '-';

  /// Converts the current [_marks] list into a 2D list representing the grid state.
  List<List<String>> _getMovesList() {
    final int n = _gridSize;
    List<List<String>> moves = List<List<String>>.generate(
      n,
      (int row) => List<String>.filled(n, _emptyCell),
    );

    for (final Mark mark in _marks) {
      moves[mark.row][mark.col] = mark.type;
    }
    return moves;
  }

  bool _checkWinner() {
    final int n = _gridSize;
    final List<List<String>> moves = _getMovesList();

    // Check rows
    for (int r = 0; r < n; r++) {
      String first = moves[r][0];
      if (first != _emptyCell &&
          List.generate(n, (c) => moves[r][c]).every((v) => v == first)) {
        return true;
      }
    }

    // Check columns
    for (int c = 0; c < n; c++) {
      String first = moves[0][c];
      if (first != _emptyCell &&
          List.generate(n, (r) => moves[r][c]).every((v) => v == first)) {
        return true;
      }
    }

    // Main diagonal
    if (moves[0][0] != _emptyCell &&
        List.generate(n, (i) => moves[i][i]).every((v) => v == moves[0][0])) {
      return true;
    }

    // Anti-diagonal
    if (moves[n - 1][0] != _emptyCell &&
        List.generate(n, (i) => moves[i][n - 1 - i]).every((v) => v == moves[n - 1][0])) {
      return true;
    }

    return false;
  }

  void _showWinnerDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text('Player "${_winnerType!}" wins!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _clearBoard();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _showDrawDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: const Text('It\'s a Draw!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _clearBoard();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _handleTap(Offset localPosition, Size boardSize) {
    if (_isGameOver) return;

    final double cellWidth = boardSize.width / _gridSize;
    final double cellHeight = boardSize.height / _gridSize;

    final int col = (localPosition.dx / cellWidth).floor();
    final int row = (localPosition.dy / cellHeight).floor();

    if (_marks.any((Mark mark) => mark.row == row && mark.col == col)) return;

    final Offset cellCenterPosition = Offset(
      col * cellWidth + (cellWidth / 2),
      row * cellHeight + (cellHeight / 2),
    );

    setState(() {
      _marks.add(Mark(
        position: cellCenterPosition,
        type: _selectedTool,
        row: row,
        col: col,
      ));

      if (_checkWinner()) {
        _isGameOver = true;
        _winnerType = _selectedTool;
        _showWinnerDialog();
      } else if (_marks.length == _gridSize * _gridSize) {
        _isGameOver = true;
        _winnerType = null;
        _showDrawDialog();
      }
    });
  }

  void _selectTool(String tool) {
    if (!_isGameOver) {
      setState(() {
        _selectedTool = tool;
      });
    }
  }

  void _clearBoard() {
    setState(() {
      _marks.clear();
      _isGameOver = false;
      _winnerType = null;
      _selectedTool = 'square'; // Reset to default tool
    });
  }
  // คืนไฟล์ save.txt
  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/ox_quicksave.txt');
  }

  // บันทึกสถานะเกมลงไฟล์
  Future<void> _quickSave() async {
    final file = await _localFile;
    final data = _marks.map((m) => '${m.row},${m.col},${m.type}').join('\n');
    await file.writeAsString(data);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game saved!')),
    );
  }

  // โหลดสถานะเกมจากไฟล์
Future<void> _quickLoad() async {
  try {
    final file = await _localFile;
    if (!await file.exists()) return;
    final contents = await file.readAsString();
    final lines = contents.split('\n');

    setState(() {
      _marks = lines.map((line) {
        final parts = line.split(',');
        final row = int.parse(parts[0]);
        final col = int.parse(parts[1]);
        final type = parts[2];

        final cellWidth = MediaQuery.of(context).size.width / _gridSize;
        final cellHeight = MediaQuery.of(context).size.width / _gridSize;

        return Mark(
          position: Offset(
            col * cellWidth + (cellWidth / 2),
            row * cellHeight + (cellHeight / 2),
          ),
          type: type,
          row: row,
          col: col,
        );
      }).toList();
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game loaded!')),
    );
  } catch (e) {
    debugPrint('Error loading game: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OX Board'), centerTitle: true),
      body: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final Size boardSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                return GestureDetector(
                  onTapDown: (details) {
                    final RenderBox? box =
                        context.findRenderObject() as RenderBox?;
                    if (box != null) {
                      final Offset localPos =
                          box.globalToLocal(details.globalPosition);
                      _handleTap(localPos, boardSize);
                    }
                  },
                  child: CustomPaint(
                    size: boardSize,
                    painter: BoardPainter(
                      marks: _marks,
                      markSize: _markSize,
                      gridSize: _gridSize,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ToolButtons(
              selectedTool: _selectedTool,
              isGameOver: _isGameOver,
              clearBoard: _clearBoard,
              selectTool: _selectTool,
              quickSave: _quickSave,
              quickLoad: _quickLoad,
            ),
          ),
        ],
      ),
    );
  }
}
