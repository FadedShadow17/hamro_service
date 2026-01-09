import 'dart:io';
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
    ImageProvider? imageProvider;
    
    if (imageUrl != null) {
      final url = imageUrl!;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        // Network image
        imageProvider = NetworkImage(url);
      } else {
        // Local file path
        final file = File(url);
        try {
          if (file.existsSync()) {
            imageProvider = FileImage(file);
          }
        } catch (e) {
          // File doesn't exist or can't be read
        }
      }
    }

    final provider = imageProvider;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[300],
        image: provider != null
            ? DecorationImage(
                image: provider,
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image loading error
                },
              )
            : null,
      ),
      child: provider == null
          ? Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.grey[600],
            )
          : null,
    );
  }
}
