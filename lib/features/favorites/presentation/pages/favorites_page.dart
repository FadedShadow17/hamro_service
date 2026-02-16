import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../presentation/providers/favorites_provider.dart';
import '../../../services/presentation/widgets/service_item_card.dart';
import '../../../booking/presentation/screens/booking_screen.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteServicesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
      ),
      body: favoritesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return _buildEmptyState(context, isDark);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoriteServicesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ServiceItemCard(
                    service: service,
                    onViewProfile: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View Profile - Coming soon')),
                      );
                    },
                    onBookNow: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(service: service),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? AppColors.textWhite50 : AppColors.textLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading favorites',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(favoriteServicesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: isDark ? AppColors.textWhite50 : AppColors.textLight,
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textWhite70 : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding services to your favorites',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textWhite50 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
