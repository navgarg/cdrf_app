import 'package:flutter/material.dart';

class LoadingCards extends StatelessWidget {
  final int count;
  final double itemHeight;

  const LoadingCards({
    super.key,
    this.count = 5,
    this.itemHeight = 76,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.primary.withAlpha(18);
    final highlight = theme.colorScheme.primary.withAlpha(35);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.1, 0.45, 0.9],
            ),
          ),
        );
      },
    );
  }
}
