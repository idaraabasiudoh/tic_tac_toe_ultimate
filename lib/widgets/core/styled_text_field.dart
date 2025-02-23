import 'package:flutter/material.dart';

class StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  const StyledTextField({
    required this.controller,
    required this.labelText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
      ),
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}