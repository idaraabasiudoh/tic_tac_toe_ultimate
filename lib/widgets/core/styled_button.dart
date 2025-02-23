import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const StyledButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: Theme.of(context).elevatedButtonTheme.style,
    );
  }
}
