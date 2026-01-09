import 'package:flutter/material.dart';

/// Reusable avatar widget
class KAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;

  const KAvatar({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[300],
        image: imageUrl != null
            ? DecorationImage(
                image: AssetImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.grey[600],
            )
          : null,
    );
  }
}
