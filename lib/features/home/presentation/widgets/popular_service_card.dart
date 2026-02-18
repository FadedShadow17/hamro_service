import 'package:flutter/material.dart';
import '../../domain/entities/popular_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../services/domain/entities/service_item.dart';
import '../../../booking/presentation/screens/booking_screen.dart';

class PopularServiceCard extends StatelessWidget {
  final PopularService service;

  const PopularServiceCard({
    super.key,
    required this.service,
  });

  IconData _getCategoryIcon(String categoryTag) {
    final tag = categoryTag.toLowerCase();
    if (tag.contains('electric') || tag.contains('electrical')) {
      return Icons.electrical_services;
    } else if (tag.contains('plumb')) {
      return Icons.plumbing;
    } else if (tag.contains('carpent')) {
      return Icons.hardware;
    } else if (tag.contains('paint')) {
      return Icons.format_paint;
    } else if (tag.contains('clean')) {
      return Icons.cleaning_services;
    } else if (tag.contains('mason') || tag.contains('construction')) {
      return Icons.construction;
    } else if (tag.contains('roof')) {
      return Icons.roofing;
    } else if (tag.contains('weld')) {
      return Icons.build;
    }
    return Icons.home_repair_service;
  }

  Color _getCategoryColor(String categoryTag) {
    final tag = categoryTag.toLowerCase();
    if (tag.contains('electric') || tag.contains('electrical')) {
      return Colors.amber;
    } else if (tag.contains('plumb')) {
      return Colors.blue;
    } else if (tag.contains('carpent')) {
      return Colors.brown;
    } else if (tag.contains('paint')) {
      return Colors.purple;
    } else if (tag.contains('clean')) {
      return Colors.teal;
    } else if (tag.contains('mason') || tag.contains('construction')) {
      return Colors.orange;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final categoryIcon = _getCategoryIcon(service.categoryTag);
    final categoryColor = _getCategoryColor(service.categoryTag);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final serviceItem = ServiceItem(
            id: service.id,
            title: service.title,
            priceRs: service.priceRs.toDouble(),
            rating: 4.5,
            reviewsCount: 0,
            categoryTag: service.categoryTag,
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookingScreen(service: serviceItem),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryIcon,
                color: categoryColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.categoryTag.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.accentYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rs ${service.priceRs.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
