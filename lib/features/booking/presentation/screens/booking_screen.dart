import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../services/domain/entities/service_item.dart';
import '../providers/booking_provider.dart';
import '../widgets/service_option_selector.dart';
import '../widgets/booking_calendar.dart';
import '../widgets/time_slot_selector.dart';
import '../widgets/service_summary_card.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final ServiceItem service;

  const BookingScreen({
    super.key,
    required this.service,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize booking state with service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).initialize(widget.service);
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleConfirmBooking() {
    final bookingState = ref.read(bookingProvider);
    
    if (bookingState.selectedServiceOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service option')),
      );
      return;
    }

    if (bookingState.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    if (bookingState.selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address')),
      );
      return;
    }

    // Update booking with address and notes
    ref.read(bookingProvider.notifier).updateAddress(_addressController.text.trim());
    ref.read(bookingProvider.notifier).updateNotes(_notesController.text.trim());

    // Create cart item from booking
    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceId: bookingState.service!.id,
      serviceName: bookingState.service!.title,
      servicePrice: bookingState.service!.priceRs,
      serviceOptionId: bookingState.selectedServiceOption!.id,
      serviceOptionName: bookingState.selectedServiceOption!.name,
      serviceOptionPrice: bookingState.selectedServiceOption!.price,
      serviceOptionDuration: bookingState.selectedServiceOption!.duration,
      selectedDate: bookingState.selectedDate!,
      selectedTimeSlot: bookingState.selectedTimeSlot!.time,
      address: _addressController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      totalPrice: bookingState.selectedServiceOption!.price,
    );

    // Add to cart
    ref.read(cartProvider.notifier).addToCart(cartItem);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking added to cart successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to dashboard, cart will be accessible via bottom nav
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingState = ref.watch(bookingProvider);

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
          'Book ${widget.service.title.toLowerCase()}',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select a service section
            Text(
              'Select a service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ServiceOptionSelector(
              serviceOptions: bookingState.serviceOptions,
              selectedOption: bookingState.selectedServiceOption,
              onOptionSelected: (option) {
                ref.read(bookingProvider.notifier).selectServiceOption(option);
              },
            ),
            const SizedBox(height: 32),

            // Select date and time section
            Text(
              'Select date and time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            BookingCalendar(
              selectedDate: bookingState.selectedDate,
              onDateSelected: (date) {
                ref.read(bookingProvider.notifier).selectDate(date);
              },
            ),
            const SizedBox(height: 20),
            // Time selection label
            Text(
              'Select time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            TimeSlotSelector(
              timeSlots: bookingState.availableTimeSlots,
              selectedTimeSlot: bookingState.selectedTimeSlot,
              onTimeSlotSelected: (timeSlot) {
                ref.read(bookingProvider.notifier).selectTimeSlot(timeSlot);
              },
            ),
            const SizedBox(height: 32),

            // Address section
            Text(
              'Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter your address',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Notes section
            Text(
              'Notes for cleaner (optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any special instructions',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Service Summary
            if (bookingState.selectedServiceOption != null)
              ServiceSummaryCard(
                serviceName: bookingState.selectedServiceOption!.name,
                price: bookingState.selectedServiceOption!.price,
                duration: bookingState.selectedServiceOption!.duration,
              ),
            const SizedBox(height: 24),

            // Confirm Booking Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleConfirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
