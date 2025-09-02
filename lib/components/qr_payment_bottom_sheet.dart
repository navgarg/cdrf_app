import 'package:flutter/material.dart';

class QrPaymentBottomSheet extends StatelessWidget {
  final VoidCallback onConfirmPaid;
  const QrPaymentBottomSheet({super.key, required this.onConfirmPaid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    return Container(
      height: 360,
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
                  Text('Scan & Pay',
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
            Text('Customer scans this code to pay',
                style:
                    TextStyle(color: onSurface.withAlpha(179))), // 0.7 opacity
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withAlpha(77)), // 0.3 opacity
              ),
              child: Center(
                child: Icon(Icons.qr_code_2_rounded, size: 160, color: primary),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Payment Received'),
                  onPressed: () {
                    // Parent handles sheet dismissal.
                    onConfirmPaid();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
