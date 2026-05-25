import 'package:flutter/material.dart';

class SuccessBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onDone;

  const SuccessBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showSuccessBottomSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String actionLabel,
  required VoidCallback onDone,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => SuccessBottomSheet(
      title: title,
      message: message,
      actionLabel: actionLabel,
      onDone: onDone,
    ),
  );
}
