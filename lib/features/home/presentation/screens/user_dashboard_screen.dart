import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/k_avatar.dart';
import '../../../../core/widgets/k_search_field.dart';
import '../../../../core/widgets/k_section_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/promo_banner.dart';
import '../widgets/most_booked_grid.dart';
import '../widgets/popular_service_card.dart';
import '../providers/home_dashboard_provider.dart';
import '../../../profile/presentation/viewmodel/profile_viewmodel.dart';
import '../../../services/presentation/screens/services_by_category_screen.dart';
import 'popular_near_you_screen.dart';

class UserDashboardScreen extends ConsumerWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardDataAsync = ref.watch(homeDashboardDataProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      body: SafeArea(
        child: dashboardDataAsync.when(
          data: (data) => _buildContent(data, ref, context),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  static Widget _buildContent(dynamic data, WidgetRef ref, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(ref, context),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const KSearchField(),
          ),
          const SizedBox(height: 16),

          const PromoBanner(),

          KSectionHeader(
            title: 'Most Booked Services',
            actionText: 'View all',
            onActionTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ServicesByCategoryScreen(
                    categoryId: 'all',
                    categoryName: 'All',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          MostBookedGrid(categories: data.mostBookedServices),
          const SizedBox(height: 24),

          KSectionHeader(
            title: 'Popular Near You',
            actionText: 'View all',
            onActionTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PopularNearYouScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          ...data.popularServices.map(
            (service) => PopularServiceCard(service: service),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _buildHeader(WidgetRef ref, BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final userName = profileState.profile?.fullName ?? 'Alex Carter';
    final avatarUrl = profileState.profile?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          KAvatar(size: 50, imageUrl: avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello 👋',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, size: 28),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.badgeBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
