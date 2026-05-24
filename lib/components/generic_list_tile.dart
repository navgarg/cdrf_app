import 'package:flutter/material.dart';

class GenericListTile extends StatelessWidget {
  final Widget leading;
  final Widget titleWidget;
  final Widget? trailing;
  final VoidCallback? onTap;

  const GenericListTile({
    super.key,
    required this.leading,
    required this.titleWidget,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = Color.lerp(
      theme.colorScheme.primary,
      theme.colorScheme.surface,
      0.72,
    )!;
    final iconBoxColor = Color.lerp(
      theme.colorScheme.primary,
      theme.colorScheme.surface,
      0.88,
    )!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: tileColor,
        borderRadius: BorderRadius.circular(10),
        elevation: 1,
        shadowColor: theme.colorScheme.primary.withAlpha(35),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBoxColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(130),
                      width: 1.2,
                    ),
                  ),
                  child: leading,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: titleWidget,
                ),
                trailing ??
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: theme.colorScheme.onSurface.withAlpha(170),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
