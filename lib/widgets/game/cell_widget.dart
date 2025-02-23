import 'package:flutter/material.dart';

class CellWidget extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const CellWidget({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: value.isEmpty
              ? Colors.transparent
              : (value == 'X' ? Colors.blue[400] : Colors.red[400]),
          border: Border.all(color: Colors.grey[800]!, width: 0.5),
          boxShadow: value.isEmpty
              ? []
              : [
                  BoxShadow(
                    color: value == 'X'
                        ? Colors.blue.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
