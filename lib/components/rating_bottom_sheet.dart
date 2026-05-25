import 'package:flutter/material.dart';

const double skippedRating = -1;

class RatingBottomSheet extends StatefulWidget {
  final void Function(double rating) onSubmit;
  const RatingBottomSheet({super.key, required this.onSubmit});

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _rating = 5; // default full rating

  void _select(int starIndex) {
    setState(() {
      _rating = starIndex + 1; // stars are 1-based for user
    });
  }

  Widget _buildStar(int index) {
    final starValue = index + 1;
    final bool filled = _rating >= starValue;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _select(index),
      child: Icon(
        filled ? Icons.star_rounded : Icons.star_border_rounded,
        size: 42,
        color: Colors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close,
                        color: onSurface.withAlpha(204)), // 0.8 opacity
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text('Rate Experience',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: onSurface)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Tap stars to rate',
                style:
                    TextStyle(color: onSurface.withAlpha(179))), // 0.7 opacity
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, _buildStar),
            ),
            const SizedBox(height: 16),
            Text(_rating.toString(),
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: onSurface)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Continue'),
                      onPressed: () {
                        // Parent is responsible for popping with a result.
                        widget.onSubmit(_rating.toDouble());
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => widget.onSubmit(skippedRating),
                      child: const Text('Skip'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
