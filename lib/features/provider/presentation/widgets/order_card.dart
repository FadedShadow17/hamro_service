import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/provider_order.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/booking_status.dart';
import '../../data/repositories/provider_repository_impl.dart';
import '../providers/provider_dashboard_provider.dart';

class OrderCard extends ConsumerWidget {
  final ProviderOrder order;

  const OrderCard({
    super.key,
    required this.order,
  });

  Color _getStatusColor(String status) {
    final upperStatus = status.toUpperCase();
    switch (upperStatus) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.declined:
        return Colors.red;
      case BookingStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return BookingStatus.toDisplayLabel(status);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(order.status);
    final upperStatus = order.status.toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(order.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs. ${order.priceRs > 0 ? order.priceRs : 1000}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (order.scheduledDate != null)
                Text(
                  'Scheduled: ${_formatDate(order.scheduledDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
            ],
          ),
          if (order.paymentStatus != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (order.paymentStatus?.toUpperCase() == 'PAID' 
                    ? Colors.green 
                    : Colors.orange).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    order.paymentStatus?.toUpperCase() == 'PAID' 
                        ? Icons.check_circle 
                        : Icons.payment,
                    size: 14,
                    color: order.paymentStatus?.toUpperCase() == 'PAID' 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.paymentStatus?.toUpperCase() == 'PAID' ? 'Paid' : 'Unpaid',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: order.paymentStatus?.toUpperCase() == 'PAID' 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (BookingStatus.canAccept(upperStatus) || 
              BookingStatus.canDecline(upperStatus) || 
              BookingStatus.canComplete(upperStatus)) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (BookingStatus.canAccept(upperStatus))
                  TextButton.icon(
                    onPressed: () => _handleAccept(ref, context),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                if (BookingStatus.canDecline(upperStatus))
                  TextButton.icon(
                    onPressed: () => _handleDecline(ref, context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                if (BookingStatus.canComplete(upperStatus))
                  TextButton.icon(
                    onPressed: () => _handleComplete(ref, context),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Complete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleAccept(WidgetRef ref, BuildContext context) async {
    try {
      final repository = ref.read(providerRepositoryProvider);
      final result = await repository.acceptBooking(order.id);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to accept: ${failure.message}')),
          );
        },
        (_) {
          ref.invalidate(providerDashboardDataProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking accepted')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleDecline(WidgetRef ref, BuildContext context) async {
    try {
      final repository = ref.read(providerRepositoryProvider);
      final result = await repository.declineBooking(order.id);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to decline: ${failure.message}')),
          );
        },
        (_) {
          ref.invalidate(providerDashboardDataProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking declined')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleComplete(WidgetRef ref, BuildContext context) async {
    try {
      final repository = ref.read(providerRepositoryProvider);
      final result = await repository.completeBooking(order.id);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to complete: ${failure.message}')),
          );
        },
        (_) {
          ref.invalidate(providerDashboardDataProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking completed')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
