import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/widgets/k_avatar.dart';
import '../../../../core/widgets/k_section_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/promo_banner.dart';
import '../widgets/popular_service_card.dart';
import '../widgets/stats_card.dart';
import '../providers/home_dashboard_provider.dart';
import '../providers/user_dashboard_stats_provider.dart';
import '../providers/search_provider.dart';
import '../../../profile/presentation/viewmodel/profile_viewmodel.dart';
import '../../../services/presentation/screens/services_by_category_screen.dart';
import '../../../booking/presentation/pages/user_bookings_page.dart';
import '../../../payment/presentation/pages/payment_page.dart';
import '../../../services/presentation/widgets/service_item_card.dart';
import '../../../services/domain/entities/service_item.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import 'popular_near_you_screen.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  ConsumerState<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).setQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardDataAsync = ref.watch(homeDashboardDataProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      body: SafeArea(
        child: dashboardDataAsync.when(
          data: (data) => _buildContent(data, ref, context, searchQuery, searchResultsAsync),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(dynamic data, WidgetRef ref, BuildContext context, String searchQuery, AsyncValue<List<ServiceItem>> searchResultsAsync) {
    final statsAsync = ref.watch(userDashboardStatsProvider);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(ref, context),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: statsAsync.when(
              data: (stats) => _buildStatsCards(context, stats),
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchField(ref, context),
          ),
          const SizedBox(height: 16),

          if (searchQuery.isNotEmpty) ...[
            _buildSearchResults(ref, context, searchResultsAsync),
          ] else ...[
            const PromoBanner(),

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
            _buildPopularServicesGrid(data.popularServices),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(WidgetRef ref, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search for any service...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(WidgetRef ref, BuildContext context, AsyncValue<List<ServiceItem>> searchResultsAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return searchResultsAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No services found',
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Results (${services.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ServiceItemCard(
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
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Error: $error',
            style: TextStyle(
              color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularServicesGrid(List<dynamic> services) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final serviceItem = ServiceItem(
            id: service.id,
            title: service.title,
            priceRs: service.priceRs.toDouble(),
            rating: 4.5,
            reviewsCount: 0,
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

  static Widget _buildStatsCards(BuildContext context, UserDashboardStats stats) {
    return Row(
      children: [
        StatsCard(
          title: 'Active Bookings',
          value: stats.activeBookings,
          icon: Icons.event_note,
          color: AppColors.accentBlue,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const UserBookingsPage(filterStatus: 'active'),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        StatsCard(
          title: 'Completed',
          value: stats.completedBookings,
          icon: Icons.check_circle,
          color: AppColors.accentGreen,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const UserBookingsPage(filterStatus: 'completed'),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        StatsCard(
          title: 'Services',
          value: stats.availableServices,
          icon: Icons.home_repair_service,
          color: AppColors.primary,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ServicesByCategoryScreen(
                  categoryId: 'all',
                  categoryName: 'All Services',
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        StatsCard(
          title: 'Pending Payments',
          value: stats.pendingPayments,
          icon: Icons.payment,
          color: AppColors.accentYellow,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PaymentPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
