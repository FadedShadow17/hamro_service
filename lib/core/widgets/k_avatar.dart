import 'dart:io';
import 'package:flutter/material.dart';
import '../config/api_config.dart';

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

  String? _normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    if (url.startsWith('/')) {
      final baseUrl = ApiConfig.baseUrl;
      final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      return '$cleanBaseUrl$url';
    }
    
    return url;
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    String? normalizedUrl;
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      normalizedUrl = _normalizeUrl(imageUrl!);
      
      if (normalizedUrl != null) {
        if (normalizedUrl.startsWith('http://') || normalizedUrl.startsWith('https://')) {
          imageProvider = NetworkImage(normalizedUrl);
        } else {
          final file = File(normalizedUrl);
          try {
            if (file.existsSync()) {
              imageProvider = FileImage(file);
            }
          } catch (e) {
          }
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
