import 'package:flutter/material.dart';

class RegularButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;

  const RegularButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      minimumSize: const Size(double.infinity, 68),
      tapTargetSize: MaterialTapTargetSize.padded,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    if (isLoading) {
      return ElevatedButton(
        onPressed: null, // Disable button when loading
        style: buttonStyle,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: theme.colorScheme.onPrimary,
            strokeWidth: 3,
          ),
        ),
      );
    } else if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: buttonStyle,
        icon: Icon(
          icon!,
          size: 30,
        ),
        label: Text(
          text,
          style: const TextStyle(fontSize: 24),
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(
          text,
          style: const TextStyle(fontSize: 24),
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
