import 'package:flutter/material.dart';
import '../l10n/dynamic_localizations.dart';

enum PaymentMethod { qr, cash }

class PaymentSelectionBottomSheet extends StatelessWidget {
  final void Function(PaymentMethod method) onSelected;
  const PaymentSelectionBottomSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    final methods = [
      {
        'icon': Icons.qr_code_2_rounded,
        'title': 'Pay via QR',
        'method': PaymentMethod.qr
      },
      {
        'icon': Icons.payments_rounded,
        'title': 'Cash',
        'method': PaymentMethod.cash
      },
    ];

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(context.tr('Select Payment'),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: onSurface)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: methods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final m = methods[idx];
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      // Parent handles bottom sheet dismissal.
                      onSelected(m['method'] as PaymentMethod);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: onSurface.withAlpha(13), // 0.05 opacity
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      child: Row(
                        children: [
                          Icon(m['icon'] as IconData, size: 34, color: primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(m['title'] as String,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: onSurface)),
                          ),
                          Icon(Icons.chevron_right,
                              color: onSurface.withAlpha(128)), // 0.5 opacity
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
