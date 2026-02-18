import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/booking_status.dart';
import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_status_badge.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../ratings/presentation/widgets/rating_dialog.dart';
import '../../../ratings/presentation/providers/rating_provider.dart';
import '../widgets/edit_booking_dialog.dart';

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
    final statusFilter = _selectedFilter == 'active' 
        ? null 
        : _selectedFilter?.toUpperCase();
    final result = await bookingRepository.getMyBookings(status: statusFilter);
    
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

  @override
  void didUpdateWidget(UserBookingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterStatus != widget.filterStatus) {
      setState(() {
        _selectedFilter = widget.filterStatus;
      });
    }
  }

  List<BookingModel> get _filteredBookings {
    if (_selectedFilter == null || _selectedFilter!.isEmpty) {
      return _bookings;
    }
    
    final filter = _selectedFilter!.toUpperCase().trim();
    
    return _bookings.where((b) {
      final status = b.status.toUpperCase().trim();
      return status == filter;
    }).toList();
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
                  _buildFilterChip('Pending', BookingStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', BookingStatus.confirmed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', BookingStatus.completed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', BookingStatus.cancelled),
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
        _loadBookings();
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
                  BookingStatusBadge(status: status),
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
              if ((status == 'CONFIRMED' || status == 'COMPLETED') && booking.provider != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      status == 'CONFIRMED' ? Icons.check_circle : Icons.person,
                      size: 16,
                      color: status == 'CONFIRMED' 
                          ? AppColors.accentGreen 
                          : (isDark ? AppColors.textWhite70 : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status == 'CONFIRMED' 
                          ? 'Accepted by ${booking.provider!['name'] ?? booking.provider!['fullName'] ?? 'Provider'}'
                          : (booking.provider!['name'] ?? booking.provider!['fullName'] ?? 'Provider'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: status == 'CONFIRMED' ? FontWeight.w600 : FontWeight.normal,
                        color: status == 'CONFIRMED' 
                            ? AppColors.accentGreen 
                            : (isDark ? AppColors.textWhite70 : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ] else if (status == 'PENDING') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 16,
                      color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Awaiting Provider',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.textWhite70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (booking.paymentStatus != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (paymentStatus == 'PAID' 
                        ? Colors.green 
                        : AppColors.accentYellow).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        paymentStatus == 'PAID' ? Icons.check_circle : Icons.payment,
                        size: 16,
                        color: paymentStatus == 'PAID' 
                            ? Colors.green 
                            : AppColors.accentYellow,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        paymentStatus == 'PAID' ? 'Paid' : 'Payment Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: paymentStatus == 'PAID' 
                              ? Colors.green 
                              : AppColors.accentYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (status == 'COMPLETED' && booking.providerId != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _rateProvider(booking),
                    icon: const Icon(Icons.star, size: 18),
                    label: const Text('Rate Provider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else if (status == 'PENDING' || status == 'CONFIRMED') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editBooking(booking),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelBooking(booking),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
                if (paymentStatus == 'UNPAID' && status == 'CONFIRMED') ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _makePayment(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Pay Now'),
                    ),
                  ),
                ],
              ] else if (BookingStatus.canCancel(status)) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _cancelBooking(booking),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Cancel Booking'),
                  ),
                ),
              ],
            ],
          ),
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

  Future<void> _editBooking(BookingModel booking) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditBookingDialog(booking: booking),
    );

    if (result == null || result.isEmpty) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final bookingRepository = ref.read(bookingRepositoryProvider);
    final updateResult = await bookingRepository.updateBooking(
      bookingId: booking.id,
      date: result['date'] as String?,
      timeSlot: result['timeSlot'] as String?,
      area: result['area'] as String?,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    updateResult.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (updatedBooking) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookings();
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadNotificationCountProvider);
      },
    );
  }

  Future<void> _rateProvider(BookingModel booking) async {
    if (booking.providerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider information not available')),
      );
      return;
    }

    final providerName = booking.provider?['name'] ?? 
                         booking.provider?['fullName'] ?? 
                         'Provider';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => RatingDialog(providerName: providerName),
    );

    if (result == null) return;

    final rating = result['rating'] as int;
    final comment = result['comment'] as String?;

    final ratingRepository = ref.read(ratingRepositoryProvider);
    final submitResult = await ratingRepository.submitRating(
      bookingId: booking.id,
      providerId: booking.providerId!,
      rating: rating,
      comment: comment,
    );

    submitResult.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully')),
        );
        _loadBookings();
      },
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
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadNotificationCountProvider);
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
          if ((booking.status.toUpperCase() == 'CONFIRMED' || booking.status.toUpperCase() == 'COMPLETED') && booking.provider != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Provider Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Name', booking.provider!['name'] ?? booking.provider!['fullName'] ?? 'N/A'),
            if (booking.provider!['phoneNumber'] != null)
              _buildDetailRow(context, 'Phone', booking.provider!['phoneNumber']),
            if (booking.provider!['serviceRole'] != null)
              _buildDetailRow(context, 'Service Role', booking.provider!['serviceRole']),
            if (booking.provider!['averageRating'] != null)
              _buildDetailRow(context, 'Rating', '${booking.provider!['averageRating']} ⭐'),
          ],
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
