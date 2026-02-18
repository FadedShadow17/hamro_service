import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/kathmandu_areas.dart';
import '../../../services/domain/entities/service_item.dart';
import '../../../services/presentation/providers/services_list_provider.dart';
import '../../../provider/presentation/providers/provider_dashboard_provider.dart';
import '../../../home/presentation/providers/user_dashboard_stats_provider.dart';
import '../../domain/repositories/booking_repository.dart';
import '../providers/booking_provider.dart';

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
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedArea;
  String? _selectedProviderId;
  List<Map<String, dynamic>> _availableProviders = [];
  bool _loadingProviders = false;
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
  }

  String _getMinDate() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(tomorrow);
  }

  String _getMaxDate() {
    final maxDate = DateTime.now().add(const Duration(days: 90));
    return DateFormat('yyyy-MM-dd').format(maxDate);
  }

  List<DateTime> _getQuickDates() {
    final dates = <DateTime>[];
    for (int i = 1; i <= 7; i++) {
      dates.add(DateTime.now().add(Duration(days: i)));
    }
    return dates;
  }

  Future<void> _fetchAvailableProviders() async {
    if (_selectedDate != null && _selectedDate!.isNotEmpty && 
        _selectedArea != null && _selectedArea!.isNotEmpty) {
      setState(() {
        _loadingProviders = true;
      });

      try {
        final servicesRepo = ref.read(servicesRepositoryProvider);
        final providers = await servicesRepo.getAvailableProviders(
          serviceId: widget.service.id,
          date: _selectedDate!,
          area: _selectedArea!,
        );

        setState(() {
          _availableProviders = providers;
          if (providers.isNotEmpty) {
            _selectedProviderId = providers[0]['providerId'] ?? '';
          } else {
            _selectedProviderId = '';
          }
          _loadingProviders = false;
        });
      } catch (e) {
        setState(() {
          _availableProviders = [];
          _selectedProviderId = '';
          _loadingProviders = false;
        });
      }
    }
  }

  void _handleDateChange(String? date) {
    setState(() {
      _selectedDate = date;
      if (_errors.containsKey('date')) {
        _errors.remove('date');
      }
    });
    if (date != null && _selectedArea != null && _selectedArea!.isNotEmpty) {
      _fetchAvailableProviders();
    }
  }

  void _handleAreaChange(String? area) {
    setState(() {
      _selectedArea = area;
      if (_errors.containsKey('area')) {
        _errors.remove('area');
      }
    });
    if (area != null && _selectedDate != null && _selectedDate!.isNotEmpty) {
      _fetchAvailableProviders();
    }
  }

  Future<void> _handleConfirmBooking() async {
    final newErrors = <String, String>{};

    if (_selectedDate == null || _selectedDate!.isEmpty) {
      newErrors['date'] = 'Please select a date';
    }
    if (_selectedTime == null || _selectedTime!.isEmpty) {
      newErrors['time'] = 'Please select a time';
    }
    if (_selectedArea == null || _selectedArea!.isEmpty) {
      newErrors['area'] = 'Please enter your location';
    }

    if (newErrors.isNotEmpty) {
      setState(() {
        _errors.addAll(newErrors);
      });
      return;
    }

    try {
      final bookingRepository = ref.read(bookingRepositoryProvider);
      
      final result = await bookingRepository.createBooking(
        serviceId: widget.service.id,
        date: _selectedDate!,
        timeSlot: _selectedTime!,
        area: _selectedArea!.trim(),
        providerId: _selectedProviderId != null && _selectedProviderId!.isNotEmpty 
            ? _selectedProviderId 
            : null,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (booking) {
          ref.invalidate(providerDashboardDataProvider);
          ref.invalidate(userDashboardStatsProvider);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking placed! Please wait for providers to accept your order'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
              ),
            );
            Navigator.of(context).pop();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimeSlot(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C3D5B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Service',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.service.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDatePicker(isDark),
                      const SizedBox(height: 20),
                      _buildTimePicker(isDark),
                      const SizedBox(height: 20),
                      _buildAreaSelector(isDark),
                      if (_selectedDate != null &&
                          _selectedDate!.isNotEmpty &&
                          _selectedArea != null &&
                          _selectedArea!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: _buildProviderSelector(isDark),
                        ),
                      const SizedBox(height: 24),
                      _buildActionButtons(isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getQuickDates().map((date) {
            final dateStr = DateFormat('yyyy-MM-dd').format(date);
            final isSelected = _selectedDate == dateStr;
            return GestureDetector(
              onTap: () => _handleDateChange(dateStr),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : (isDark ? const Color(0xFF0A2640) : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
                  ),
                ),
                child: Text(
                  DateFormat('EEE, MMM d').format(date),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: _selectedDate),
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (picked != null) {
              _handleDateChange(DateFormat('yyyy-MM-dd').format(picked));
            }
          },
          decoration: InputDecoration(
            hintText: 'Select date',
            prefixIcon: Icon(
              Icons.calendar_today,
              color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0A2640) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errors.containsKey('date')
                    ? Colors.red
                    : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errors.containsKey('date')
                    ? Colors.red
                    : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (_selectedDate != null && _selectedDate!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(_selectedDate!)),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
              ),
            ),
          ),
        if (_errors.containsKey('date'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errors['date']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTimePicker(bool isDark) {
    final quickTimes = ['09:00', '12:00', '15:00', '18:00'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: quickTimes.map((slot) {
            final isSelected = _selectedTime == slot;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = slot;
                      if (_errors.containsKey('time')) {
                        _errors.remove('time');
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : (isDark ? const Color(0xFF0A2640) : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      _formatTimeSlot(slot),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: _selectedTime),
          readOnly: true,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              final hour = picked.hour.toString().padLeft(2, '0');
              final minute = picked.minute.toString().padLeft(2, '0');
              setState(() {
                _selectedTime = '$hour:$minute';
                if (_errors.containsKey('time')) {
                  _errors.remove('time');
                }
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Select time',
            prefixIcon: Icon(
              Icons.access_time,
              color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0A2640) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errors.containsKey('time')
                    ? Colors.red
                    : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errors.containsKey('time')
                    ? Colors.red
                    : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (_selectedTime != null && _selectedTime!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTimeSlot(_selectedTime!),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
              ),
            ),
          ),
        if (_errors.containsKey('time'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errors['time']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildAreaSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location (Choose your current location)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedArea,
          decoration: InputDecoration(
            hintText: 'Select area',
            prefixIcon: Icon(
              Icons.location_on,
              color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0A2640) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errors.containsKey('area')
                    ? Colors.red
                    : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errors.containsKey('area')
                    ? Colors.red
                    : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
          ),
          dropdownColor: isDark ? const Color(0xFF1C3D5B) : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          items: KathmanduAreas.areas.map((area) {
            return DropdownMenuItem<String>(
              value: area,
              child: Text(area),
            );
          }).toList(),
          onChanged: (value) => _handleAreaChange(value),
        ),
        if (_errors.containsKey('area'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errors['area']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildProviderSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Provider (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (_loadingProviders)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A2640) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                'Loading available providers...',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          )
        else if (_availableProviders.isNotEmpty)
          Column(
            children: [
              RadioListTile<String>(
                title: Text(
                  'Auto-assign provider',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  "We'll assign an available provider for you",
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                value: '',
                groupValue: _selectedProviderId ?? '',
                onChanged: (value) {
                  setState(() {
                    _selectedProviderId = value;
                  });
                },
                activeColor: AppColors.primaryBlue,
                contentPadding: EdgeInsets.zero,
              ),
              ..._availableProviders.map((provider) {
                final providerId = provider['providerId'] ?? '';
                final providerName = provider['providerName'] ?? 'Provider';
                final area = provider['area'] ?? '';
                final price = provider['price'] ?? 0;
                return RadioListTile<String>(
                  title: Text(
                    providerName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '$area • Rs. ${price.toString()}',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  value: providerId,
                  groupValue: _selectedProviderId ?? '',
                  onChanged: (value) {
                    setState(() {
                      _selectedProviderId = value;
                    });
                  },
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'No specific providers available. A provider will be automatically assigned when you confirm your booking.',
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!,
              ),
              backgroundColor: isDark ? const Color(0xFF0A2640) : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
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
      ],
    );
  }
}
