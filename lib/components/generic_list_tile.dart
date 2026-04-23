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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 16),
                Expanded(
                  child: titleWidget,
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
