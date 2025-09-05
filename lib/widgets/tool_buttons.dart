import 'package:flutter/material.dart';

class ToolButtons extends StatelessWidget {
  final String selectedTool;
  final bool isGameOver;
  final VoidCallback clearBoard;
  final ValueChanged<String> selectTool;
  final VoidCallback quickSave;
  final VoidCallback quickLoad;

  const ToolButtons({
    super.key,
    required this.selectedTool,
    required this.isGameOver,
    required this.clearBoard,
    required this.selectTool,
    required this.quickSave,
    required this.quickLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton.icon(
          onPressed: isGameOver ? null : () => selectTool('square'),
          icon: const Icon(Icons.square_outlined),
          label: const Text('Draw Square'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedTool == 'square' ? Colors.blue.shade100 : null,
            foregroundColor:
                selectedTool == 'square' ? Colors.blue.shade800 : null,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          onPressed: isGameOver ? null : () => selectTool('triangle'),
          icon: const Icon(Icons.change_history),
          label: const Text('Draw Triangle'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedTool == 'triangle' ? Colors.red.shade100 : null,
            foregroundColor:
                selectedTool == 'triangle' ? Colors.red.shade800 : null,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          onPressed: clearBoard,
          icon: const Icon(Icons.delete_sweep_outlined),
          label: const Text('Clear All'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.grey.shade800,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          onPressed: isGameOver ? null : () => quickSave(),
          icon: const Icon(Icons.save),
          label: const Text('Quick Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.grey.shade800,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          onPressed: isGameOver ? null : () => quickLoad(),
          icon: const Icon(Icons.restore),
          label: const Text('Quick Load'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.grey.shade800,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}