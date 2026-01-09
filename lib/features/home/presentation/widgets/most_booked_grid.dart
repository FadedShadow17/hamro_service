import 'package:flutter/material.dart';
import '../../domain/entities/service_category.dart';

/// Most booked services grid widget
class MostBookedGrid extends StatelessWidget {
  final List<ServiceCategory> categories;

  const MostBookedGrid({
    super.key,
    required this.categories,
  });

  IconData _getIcon(String iconKey) {
    switch (iconKey) {
      case 'plumber':
        return Icons.plumbing;
      case 'electrician':
        return Icons.electrical_services;
      case 'carpenter':
        return Icons.carpenter;
      case 'painter':
        return Icons.format_paint;
      case 'mason':
        return Icons.construction;
      case 'welder':
        return Icons.build;
      case 'roofer':
        return Icons.roofing;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _ServiceCategoryCard(
          category: category,
          icon: _getIcon(category.iconKey),
        );
      },
    );
  }
}

class _ServiceCategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final IconData icon;

  const _ServiceCategoryCard({
    required this.category,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
