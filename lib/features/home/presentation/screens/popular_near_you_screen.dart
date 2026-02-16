import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_dashboard_provider.dart';
import '../../../services/presentation/widgets/service_item_card.dart';
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
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Popular Near You',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: dashboardDataAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: data.popularServices.length,
            itemBuilder: (context, index) {
              final service = data.popularServices[index];
              final serviceItem = ServiceItem(
                id: service.id,
                title: service.title,
                priceRs: service.priceRs.toDouble(),
                rating: 4.5,
                reviewsCount: 120,
                categoryTag: service.categoryTag,
              );
              return ServiceItemCard(
                service: serviceItem,
                onViewProfile: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View Profile - Coming soon')),
                  );
                },
                onBookNow: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(service: serviceItem),
                    ),
                  );
                },
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
