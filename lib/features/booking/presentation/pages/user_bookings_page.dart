import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';

class UserBookingsPage extends ConsumerStatefulWidget {
  final String? filterStatus; // 'active', 'completed', 'pending', 'confirmed', 'cancelled', or null for all

  const UserBookingsPage({
    super.key,
    this.filterStatus,
  });

  @override
  ConsumerState<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends ConsumerState<UserBookingsPage> {
  String? _selectedFilter;
  bool _isLoading = false;
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.filterStatus;
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final result = await bookingRepository.getMyBookings();
    
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _bookings = [];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load bookings: ${failure.message}')),
          );
        }
      },
      (bookings) {
        setState(() {
          _isLoading = false;
          _bookings = bookings;
        });
      },
    );
  }

  List<BookingModel> get _filteredBookings {
    if (_selectedFilter == null) return _bookings;
    
    switch (_selectedFilter!.toLowerCase()) {
      case 'active':
        return _bookings.where((b) => 
          b.status.toUpperCase() == 'PENDING' || 
          b.status.toUpperCase() == 'CONFIRMED'
        ).toList();
      case 'completed':
        return _bookings.where((b) => 
          b.status.toUpperCase() == 'COMPLETED'
        ).toList();
      case 'pending':
        return _bookings.where((b) => 
          b.status.toUpperCase() == 'PENDING'
        ).toList();
      case 'confirmed':
        return _bookings.where((b) => 
          b.status.toUpperCase() == 'CONFIRMED'
        ).toList();
      case 'cancelled':
        return _bookings.where((b) => 
          b.status.toUpperCase() == 'CANCELLED'
        ).toList();
      default:
        return _bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
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
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active', 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', 'confirmed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),
          
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            return _buildBookingCard(_filteredBookings[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : null;
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

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: isDark ? AppColors.textWhite50 : AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == null
                ? 'You haven\'t made any bookings yet'
                : 'No $_selectedFilter bookings found',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textWhite50 : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = booking.status.toUpperCase();
    final paymentStatus = booking.paymentStatus?.toUpperCase() ?? 'UNPAID';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
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
                      booking.service?['name'] ?? booking.service?['title'] ?? 'Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  _buildStatusBadge(status),
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
                    _formatDate(booking.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.timeSlot,
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
                      booking.area,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (booking.provider != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking.provider!['name'] ?? booking.provider!['fullName'] ?? 'Provider',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (paymentStatus == 'UNPAID' && status == 'CONFIRMED') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payment,
                        size: 16,
                        color: AppColors.accentYellow,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accentYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == 'PENDING' || status == 'CONFIRMED')
                    TextButton(
                      onPressed: () => _cancelBooking(booking),
                      child: const Text('Cancel'),
                    ),
                  if (paymentStatus == 'UNPAID' && status == 'CONFIRMED')
                    ElevatedButton(
                      onPressed: () => _makePayment(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Pay Now'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailsSheet(booking: booking),
    );
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
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
      final bookingRepository = ref.read(bookingRepositoryProvider);
      final result = await bookingRepository.cancelBooking(booking.id);
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel booking: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
          _loadBookings();
        },
      );
    }
  }

  void _makePayment(BookingModel booking) {
    // Navigate to payment page
    Navigator.of(context).pushNamed('/payment', arguments: booking);
  }
}

class _BookingDetailsSheet extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailsSheet({required this.booking});

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
            'Booking Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(context, 'Service', booking.service?['name'] ?? booking.service?['title'] ?? 'N/A'),
          _buildDetailRow(context, 'Date', _formatDate(booking.date)),
          _buildDetailRow(context, 'Time', booking.timeSlot),
          _buildDetailRow(context, 'Area', booking.area),
          _buildDetailRow(context, 'Status', booking.status),
          if (booking.paymentStatus != null)
            _buildDetailRow(context, 'Payment Status', booking.paymentStatus!),
          if (booking.paymentMethod != null)
            _buildDetailRow(context, 'Payment Method', booking.paymentMethod!),
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
