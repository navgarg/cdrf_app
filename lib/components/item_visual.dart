import 'package:flutter/material.dart';

class ItemVisual extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color iconColor;
  final double size;
  final double iconSize;

  const ItemVisual({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.iconColor,
    this.size = 50,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final image = imageUrl?.trim();
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(102),
        borderRadius: BorderRadius.circular(15),
      ),
      child: image == null || image.isEmpty
          ? Icon(fallbackIcon, size: iconSize, color: iconColor)
          : Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(fallbackIcon, size: iconSize, color: iconColor);
              },
            ),
    );
  }
}
