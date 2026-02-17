import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_dashboard_provider.dart';
import '../../../services/presentation/widgets/service_grid_card.dart';
import '../../../services/domain/entities/service_item.dart';
import '../../../booking/presentation/screens/booking_screen.dart';

class PopularNearYouScreen extends ConsumerWidget {
  const PopularNearYouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardDataAsync = ref.watch(homeDashboardDataProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Popular Near You',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1E1E1E),
                            const Color(0xFF121212),
                          ]
                        : [
                            AppColors.primaryBlue.withValues(alpha: 0.1),
                            AppColors.accentBlue.withValues(alpha: 0.05),
                          ],
                  ),
                ),
              ),
            ),
          ),
          dashboardDataAsync.when(
            data: (data) {
              if (data.popularServices.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 64,
                          color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No services available',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final service = data.popularServices[index];
                      final serviceItem = ServiceItem(
                        id: service.id,
                        title: service.title,
                        priceRs: service.priceRs.toDouble(),
                        rating: 4.5,
                        reviewsCount: 120,
                        categoryTag: service.categoryTag,
                      );
                      return ServiceGridCard(
                        service: serviceItem,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BookingScreen(service: serviceItem),
                            ),
                          );
                        },
                      );
                    },
                    childCount: data.popularServices.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.accentRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading services',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
