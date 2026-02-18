import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/pricing_helper.dart';
import '../../domain/entities/service_item.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';

class ServiceGridCard extends ConsumerWidget {
  final ServiceItem service;
  final VoidCallback? onTap;

  const ServiceGridCard({
    super.key,
    required this.service,
    this.onTap,
  });

  IconData _getServiceIcon(String categoryTag) {
    final category = categoryTag.toLowerCase();
    if (category.contains('cleaning') || category.contains('clean')) {
      return Icons.cleaning_services;
    } else if (category.contains('plumbing') || category.contains('plumber')) {
      return Icons.plumbing;
    } else if (category.contains('electrical') || category.contains('electric')) {
      return Icons.electrical_services;
    } else if (category.contains('carpentry') || category.contains('carpenter')) {
      return Icons.build;
    } else if (category.contains('painting') || category.contains('paint')) {
      return Icons.format_paint;
    } else if (category.contains('gardening') || category.contains('garden')) {
      return Icons.local_florist;
    } else if (category.contains('appliance') || category.contains('repair')) {
      return Icons.build_circle;
    }
    return Icons.home_repair_service;
  }

  List<Color> _getServiceGradient(String categoryTag) {
    final category = categoryTag.toLowerCase();
    if (category.contains('cleaning') || category.contains('clean')) {
      return [
        Colors.blue.withValues(alpha: 0.15),
        Colors.lightBlue.withValues(alpha: 0.08),
      ];
    } else if (category.contains('plumbing') || category.contains('plumber')) {
      return [
        Colors.cyan.withValues(alpha: 0.15),
        Colors.blue.withValues(alpha: 0.08),
      ];
    } else if (category.contains('electrical') || category.contains('electric')) {
      return [
        Colors.amber.withValues(alpha: 0.15),
        Colors.orange.withValues(alpha: 0.08),
      ];
    } else if (category.contains('carpentry') || category.contains('carpenter')) {
      return [
        Colors.brown.withValues(alpha: 0.15),
        Colors.orange.withValues(alpha: 0.08),
      ];
    } else if (category.contains('painting') || category.contains('paint')) {
      return [
        Colors.purple.withValues(alpha: 0.15),
        Colors.pink.withValues(alpha: 0.08),
      ];
    } else if (category.contains('gardening') || category.contains('garden')) {
      return [
        Colors.green.withValues(alpha: 0.15),
        Colors.lightGreen.withValues(alpha: 0.08),
      ];
    } else if (category.contains('appliance') || category.contains('repair')) {
      return [
        Colors.red.withValues(alpha: 0.15),
        Colors.orange.withValues(alpha: 0.08),
      ];
    }
    return [
      AppColors.primaryBlue.withValues(alpha: 0.1),
      AppColors.accentBlue.withValues(alpha: 0.05),
    ];
  }

  Color _getServiceIconColor(String categoryTag) {
    final category = categoryTag.toLowerCase();
    if (category.contains('cleaning') || category.contains('clean')) {
      return Colors.blue;
    } else if (category.contains('plumbing') || category.contains('plumber')) {
      return Colors.cyan;
    } else if (category.contains('electrical') || category.contains('electric')) {
      return Colors.amber.shade700;
    } else if (category.contains('carpentry') || category.contains('carpenter')) {
      return Colors.brown;
    } else if (category.contains('painting') || category.contains('paint')) {
      return Colors.purple;
    } else if (category.contains('gardening') || category.contains('garden')) {
      return Colors.green;
    } else if (category.contains('appliance') || category.contains('repair')) {
      return Colors.red;
    }
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final isFavoriteAsync = ref.watch(isFavoriteProvider(service.id));
    final serviceIcon = _getServiceIcon(service.categoryTag);
    final gradientColors = _getServiceGradient(service.categoryTag);
    final iconColor = _getServiceIconColor(service.categoryTag);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        serviceIcon,
                        size: 48,
                        color: iconColor.withValues(alpha: 0.6),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: isFavoriteAsync.when(
                        data: (isFav) => GestureDetector(
                          onTap: () async {
                            final repository = ref.read(favoritesRepositoryProvider);
                            if (isFav) {
                              await repository.removeFavorite(service.id);
                            } else {
                              await repository.addFavorite(service.id);
                            }
                            ref.invalidate(isFavoriteProvider(service.id));
                            ref.invalidate(favoriteServicesProvider);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFav ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        service.categoryTag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.accentYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs ${PricingHelper.getPriceWithFallback(service.priceRs, service.categoryTag).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
