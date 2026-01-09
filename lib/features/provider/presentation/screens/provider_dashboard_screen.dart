import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/k_avatar.dart';
import '../../../../core/widgets/k_section_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/provider_dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/order_card.dart';
import '../../../profile/presentation/viewmodel/profile_viewmodel.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardDataAsync = ref.watch(providerDashboardDataProvider);

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

          // Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Total Orders',
                    value: '${data.stats.totalOrders}',
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.badgeBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Pending',
                    value: '${data.stats.pendingOrders}',
                    icon: Icons.pending_outlined,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Completed',
                    value: '${data.stats.completedOrders}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Earnings',
                    value: 'Rs. ${data.stats.totalEarnings}',
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Rating Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${data.stats.averageRating}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Average Rating',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).dividerColor,
                  ),
                  Column(
                    children: [
                      Text(
                        '${data.stats.totalReviews}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Reviews',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pending Orders
          if (data.pendingOrders.isNotEmpty) ...[
            KSectionHeader(
              title: 'Pending Orders',
              actionText: 'View all',
              onActionTap: () {},
            ),
            const SizedBox(height: 8),
            ...data.pendingOrders.map(
              (order) => OrderCard(order: order),
            ),
            const SizedBox(height: 24),
          ],

          // Active Orders
          if (data.activeOrders.isNotEmpty) ...[
            KSectionHeader(
              title: 'Active Orders',
              actionText: 'View all',
              onActionTap: () {},
            ),
            const SizedBox(height: 8),
            ...data.activeOrders.map(
              (order) => OrderCard(order: order),
            ),
            const SizedBox(height: 24),
          ],

          // Recent Orders
          KSectionHeader(
            title: 'Recent Orders',
            actionText: 'View all',
            onActionTap: () {},
          ),
          const SizedBox(height: 8),
          ...data.recentOrders.map(
            (order) => OrderCard(order: order),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _buildHeader(WidgetRef ref, BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final userName = profileState.profile?.fullName ?? 'Provider';
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
                  'Welcome Back 👋',
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
                    '3',
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
