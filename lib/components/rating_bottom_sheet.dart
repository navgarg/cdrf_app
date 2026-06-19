import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/providers/locale_provider.dart';
import 'package:nariudyam/services/voice/voice_output_service.dart';

const double skippedRating = -1;

class RatingBottomSheet extends ConsumerStatefulWidget {
  final void Function(double rating) onSubmit;
  const RatingBottomSheet({super.key, required this.onSubmit});

  @override
  ConsumerState<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends ConsumerState<RatingBottomSheet> {
  int _rating = 5; // default full rating

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      VoiceOutputService.instance.speak(
        text: 'How was the customer experience?',
        languageCode: ref.read(localeProvider).languageCode,
      );
    });
  }

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
        size: 50,
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
      height: 420,
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
                  Text(context.tr('Rate Experience'),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: onSurface)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Icon(Icons.record_voice_over_outlined, color: primary, size: 34),
            const SizedBox(height: 8),
            Text(context.tr('Tap stars to rate'),
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
                      label: Text(context.tr('Continue')),
                      onPressed: () {
                        // Parent is responsible for popping with a result.
                        widget.onSubmit(_rating.toDouble());
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onSubmit(skippedRating),
                      icon: const Icon(Icons.skip_next),
                      label: Text(context.tr('Skip')),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Skip feedback'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
