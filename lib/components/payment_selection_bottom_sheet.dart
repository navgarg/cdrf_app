import 'package:flutter/material.dart';
import '../l10n/dynamic_localizations.dart';

enum PaymentMethod { qr, cash }

class PaymentSelectionBottomSheet extends StatefulWidget {
  final void Function(PaymentMethod method) onSelected;
  const PaymentSelectionBottomSheet({super.key, required this.onSelected});

  @override
  State<PaymentSelectionBottomSheet> createState() =>
      _PaymentSelectionBottomSheetState();
}

class _PaymentSelectionBottomSheetState
    extends State<PaymentSelectionBottomSheet> {
  PaymentMethod? _selectedMethod;

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
      height: 360,
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
                          fontSize: 20,
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
                  final method = m['method'] as PaymentMethod;
                  final selected = _selectedMethod == method;
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() => _selectedMethod = method);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            selected ? primary.withAlpha(30) : theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected ? primary : Colors.transparent,
                          width: 2,
                        ),
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
                          Icon(m['icon'] as IconData, size: 42, color: primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(m['title'] as String,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: onSurface)),
                          ),
                          Icon(
                            selected ? Icons.check_circle : Icons.chevron_right,
                            color:
                                selected ? primary : onSurface.withAlpha(128),
                            size: selected ? 28 : 24,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedMethod == null
                      ? null
                      : () => widget.onSelected(_selectedMethod!),
                  icon: const Icon(Icons.check),
                  label: Text(context.tr('Continue')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
