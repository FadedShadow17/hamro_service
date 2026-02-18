import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/k_avatar.dart';
import '../../../../core/widgets/k_section_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/provider_dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/order_card.dart';
import '../../../profile/presentation/viewmodel/profile_viewmodel.dart';
import '../pages/provider_verification_page.dart';
import '../pages/provider_bookings_page.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import 'dart:async';

class ProviderDashboardScreen extends ConsumerStatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  ConsumerState<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends ConsumerState<ProviderDashboardScreen> with WidgetsBindingObserver {
  Timer? _notificationRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
      ref.invalidate(providerDashboardDataProvider);
    });
    _startNotificationRefreshTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
      ref.invalidate(providerDashboardDataProvider);
      _startNotificationRefreshTimer();
    } else {
      _notificationRefreshTimer?.cancel();
    }
  }

  void _startNotificationRefreshTimer() {
    _notificationRefreshTimer?.cancel();
    _notificationRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadNotificationCountProvider);
        ref.invalidate(providerDashboardDataProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardDataAsync = ref.watch(providerDashboardDataProvider);
    final verificationStatusAsync = ref.watch(providerVerificationStatusForDashboardProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      body: SafeArea(
        child: verificationStatusAsync.when(
          data: (verificationSummary) {
            final status = verificationSummary['status'] as String? ?? 'NOT_SUBMITTED';
            final isApproved = status == 'APPROVED';
            
            if (!isApproved) {
              return _buildVerificationRequired(context, isDark, status);
            }
            
            return dashboardDataAsync.when(
              data: (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(providerDashboardDataProvider);
                  ref.invalidate(providerVerificationStatusForDashboardProvider);
                  await Future.wait([
                    ref.read(providerDashboardDataProvider.future),
                    ref.read(providerVerificationStatusForDashboardProvider.future),
                  ]);
                },
                child: _buildContent(data, ref, context, verificationSummary),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(providerDashboardDataProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {

            return dashboardDataAsync.when(
              data: (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(providerDashboardDataProvider);
                  await ref.read(providerDashboardDataProvider.future);
                },
                child: _buildContent(data, ref, context, {}),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(providerDashboardDataProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildContent(dynamic data, WidgetRef ref, BuildContext context, Map<String, dynamic> verificationSummary) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(ref, context, verificationSummary),
          const SizedBox(height: 16),

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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProviderBookingsPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Pending',
                    value: '${data.stats.pendingOrders}',
                    icon: Icons.pending_outlined,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProviderBookingsPage(filterStatus: 'PENDING'),
                        ),
                      );
                    },
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProviderBookingsPage(filterStatus: 'COMPLETED'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Earnings',
                    value: 'Rs. ${data.stats.totalEarnings}',
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProviderBookingsPage(filterStatus: 'COMPLETED'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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

          if (data.pendingOrders.isNotEmpty) ...[
            KSectionHeader(
              title: 'Pending Orders',
              actionText: 'View all',
              onActionTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProviderBookingsPage(filterStatus: 'pending'),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ...data.pendingOrders.map(
              (order) => OrderCard(order: order),
            ),
            const SizedBox(height: 24),
          ],

          if (data.activeOrders.isNotEmpty) ...[
            KSectionHeader(
              title: 'Active Orders',
              actionText: 'View all',
              onActionTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProviderBookingsPage(filterStatus: 'confirmed'),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ...data.activeOrders.map(
              (order) => OrderCard(order: order),
            ),
            const SizedBox(height: 24),
          ],

          if (data.recentOrders.isNotEmpty) ...[
            KSectionHeader(
              title: 'Recent Orders',
              actionText: 'View all',
              onActionTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProviderBookingsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ...data.recentOrders.map(
              (order) => OrderCard(order: order),
            ),
            const SizedBox(height: 24),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No recent orders',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildHeader(WidgetRef ref, BuildContext context, Map<String, dynamic> verificationSummary) {
    final profileState = ref.watch(profileViewModelProvider);
    final userName = profileState.profile?.fullName ?? 'Provider';
    final avatarUrl = profileState.profile?.avatarUrl;
    final profession = verificationSummary['serviceRole'] as String?;

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
                  'Welcome Back',
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
                if (profession != null && profession!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    profession!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500]
                          : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
              return unreadCountAsync.when(
                data: (count) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.badgeBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                loading: () => IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 28),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                error: (_, __) => IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 28),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRequired(BuildContext context, bool isDark, String status) {
    String statusText;
    String description;
    Color statusColor;

    if (status == 'PENDING_REVIEW') {
      statusText = 'Pending Review';
      description = 'Your verification is under review. Please wait for approval.';
      statusColor = Colors.orange;
    } else if (status == 'REJECTED') {
      statusText = 'Rejected';
      description = 'Your verification was rejected. Please resubmit your verification.';
      statusColor = Colors.red;
    } else {
      statusText = 'Verification Required';
      description = 'Please complete verification to browse user requests.';
      statusColor = Colors.blue;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user,
                size: 80,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProviderVerificationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  status == 'REJECTED' ? 'Resubmit Verification' : 'Complete Verification',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
