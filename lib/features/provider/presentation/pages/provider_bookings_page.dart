import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/booking_status.dart';
import '../../domain/entities/provider_order.dart';
import '../providers/provider_dashboard_provider.dart';

class ProviderBookingsPage extends ConsumerStatefulWidget {
  final String? filterStatus;

  const ProviderBookingsPage({
    super.key,
    this.filterStatus,
  });

  @override
  ConsumerState<ProviderBookingsPage> createState() => _ProviderBookingsPageState();
}

class _ProviderBookingsPageState extends ConsumerState<ProviderBookingsPage> {
  String? _selectedFilter;
  bool _isLoading = false;
  List<ProviderOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.filterStatus;
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    final providerRepository = ref.read(providerRepositoryProvider);
    final result = await providerRepository.getProviderBookings(status: _selectedFilter);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _orders = [];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load orders: ${failure.message}')),
          );
        }
      },
      (orders) {
        setState(() {
          _isLoading = false;
          _orders = orders;
        });
      },
    );
  }

  List<ProviderOrder> get _filteredOrders {
    if (_selectedFilter == null || _selectedFilter == 'all') return _orders;
    return _orders.where((o) => o.status.toLowerCase() == _selectedFilter!.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Jobs'),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', 'confirmed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Declined', 'declined'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(context, _filteredOrders[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : null;
          _loadOrders();
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.textWhite70 : AppColors.textSecondary),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off,
            size: 64,
            color: isDark ? AppColors.textWhite50 : AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == null || _selectedFilter == 'all'
                ? 'You don\'t have any jobs yet'
                : 'No $_selectedFilter jobs found',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textWhite50 : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, ProviderOrder order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final upperStatus = order.status.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.serviceName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.scheduledDate != null
                        ? DateFormat('MMM dd, yyyy').format(order.scheduledDate!)
                        : 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.person,
                    size: 16,
                    color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.customerName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (BookingStatus.canAccept(upperStatus) ||
                  BookingStatus.canDecline(upperStatus) ||
                  BookingStatus.canComplete(upperStatus)) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (BookingStatus.canAccept(upperStatus))
                      TextButton.icon(
                        onPressed: () => _handleAccept(context, order),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Accept'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentGreen,
                        ),
                      ),
                    if (BookingStatus.canDecline(upperStatus))
                      TextButton.icon(
                        onPressed: () => _handleDecline(context, order),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Decline'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentRed,
                        ),
                      ),
                    if (BookingStatus.canComplete(upperStatus))
                      TextButton.icon(
                        onPressed: () => _handleComplete(context, order),
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('Complete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentBlue,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toUpperCase()) {
      case 'PENDING':
        color = AppColors.statusPending;
        label = 'Pending';
        break;
      case 'CONFIRMED':
        color = AppColors.statusConfirmed;
        label = 'Confirmed';
        break;
      case 'COMPLETED':
        color = AppColors.statusCompleted;
        label = 'Completed';
        break;
      case 'CANCELLED':
        color = AppColors.statusCancelled;
        label = 'Cancelled';
        break;
      case 'DECLINED':
        color = AppColors.statusRejected;
        label = 'Declined';
        break;
      default:
        color = AppColors.textLight;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, ProviderOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailsSheet(context: context, order: order),
    );
  }

  Future<void> _handleAccept(BuildContext context, ProviderOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Job'),
        content: const Text('Are you sure you want to accept this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(providerRepositoryProvider);
      final result = await repository.acceptBooking(order.id);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to accept job: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job accepted successfully')),
          );
          _loadOrders();
          ref.invalidate(providerDashboardDataProvider);
        },
      );
    }
  }

  Future<void> _handleDecline(BuildContext context, ProviderOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Job'),
        content: const Text('Are you sure you want to decline this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(providerRepositoryProvider);
      final result = await repository.declineBooking(order.id);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to decline job: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job declined successfully')),
          );
          _loadOrders();
          ref.invalidate(providerDashboardDataProvider);
        },
      );
    }
  }

  Future<void> _handleComplete(BuildContext context, ProviderOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Job'),
        content: const Text('Are you sure you want to mark this job as complete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(providerRepositoryProvider);
      final result = await repository.completeBooking(order.id);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to complete job: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job marked as complete')),
          );
          _loadOrders();
          ref.invalidate(providerDashboardDataProvider);
        },
      );
    }
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final ProviderOrder order;
  final BuildContext context;

  const _OrderDetailsSheet({required this.context, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Job Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(context, 'Service', order.serviceName),
          _buildDetailRow(context, 'Customer', order.customerName),
          _buildDetailRow(context, 'Date', order.scheduledDate != null ? DateFormat('MMM dd, yyyy').format(order.scheduledDate!) : 'N/A'),
          _buildDetailRow(context, 'Location', order.location),
          _buildDetailRow(context, 'Status', order.status),
          _buildDetailRow(context, 'Price', 'Rs. ${order.priceRs.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
