import 'package:flutter/material.dart';

class DomainCard extends StatelessWidget {
  final String label;
  final String iconAssetPath;
  final VoidCallback onTap;

  const DomainCard({
    super.key,
    required this.label,
    required this.iconAssetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconAssetPath,
                height: 72,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.business, size: 72);
                },
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
