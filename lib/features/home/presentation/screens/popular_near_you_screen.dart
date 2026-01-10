import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_dashboard_provider.dart';
import '../widgets/premium_service_card.dart';
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
            expandedHeight: 120,
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
                  fontSize: 18,
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
                            AppColors.gradientBlueStart.withValues(alpha: 0.1),
                            AppColors.gradientBlueEnd.withValues(alpha: 0.1),
                          ],
                  ),
                ),
              ),
            ),
          ),
          dashboardDataAsync.when(
            data: (data) => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = data.popularServices[index];
                    // Convert PopularService to ServiceItem for booking
                    final serviceItem = ServiceItem(
                      id: service.id,
                      title: service.title,
                      priceRs: service.priceRs.toDouble(),
                      rating: 4.5,
                      reviewsCount: 120,
                      categoryTag: service.categoryTag,
                    );
                    return PremiumServiceCard(
                      service: serviceItem,
                      onBookNow: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              service: serviceItem,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: data.popularServices.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
