import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/booking_model.dart';
import '../../presentation/providers/booking_provider.dart';

class EditBookingDialog extends ConsumerStatefulWidget {
  final BookingModel booking;

  const EditBookingDialog({
    super.key,
    required this.booking,
  });

  @override
  ConsumerState<EditBookingDialog> createState() => _EditBookingDialogState();
}

class _EditBookingDialogState extends ConsumerState<EditBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _timeSlotController;
  late TextEditingController _areaController;
  DateTime? _selectedDate;
  List<String> _availableTimeSlots = [];
  bool _isLoadingTimeSlots = false;
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.booking.date);
    _timeSlotController = TextEditingController(text: widget.booking.timeSlot);
    _areaController = TextEditingController(text: widget.booking.area);
    _selectedDate = DateTime.tryParse(widget.booking.date);
    _selectedTimeSlot = widget.booking.timeSlot;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailableTimeSlots();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeSlotController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _selectedTimeSlot = null;
        _availableTimeSlots = [];
      });
      await _loadAvailableTimeSlots();
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null || widget.booking.service == null) return;

    final serviceId = widget.booking.service?['_id'] ?? widget.booking.service?['id'];
    if (serviceId == null) return;

    setState(() {
      _isLoadingTimeSlots = true;
    });

    try {
      final bookingRepository = ref.read(bookingRepositoryProvider);
      final result = await bookingRepository.getAvailableTimeSlotsFromAPI(
        serviceId: serviceId,
        date: _dateController.text,
        area: _areaController.text.trim(),
      );

      result.fold(
        (_) {
          setState(() {
            _isLoadingTimeSlots = false;
            _availableTimeSlots = [];
          });
        },
        (timeSlots) {
          setState(() {
            _isLoadingTimeSlots = false;
            _availableTimeSlots = timeSlots.map((slot) => slot.time).toList();
            if (_availableTimeSlots.isNotEmpty && _selectedTimeSlot == null) {
              _selectedTimeSlot = _availableTimeSlots.first;
              _timeSlotController.text = _selectedTimeSlot!;
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoadingTimeSlots = false;
        _availableTimeSlots = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Dialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Booking',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_availableTimeSlots.isEmpty && !_isLoadingTimeSlots)
                TextFormField(
                  controller: _timeSlotController,
                  decoration: InputDecoration(
                    labelText: 'Time Slot',
                    hintText: 'e.g., 10:00 AM - 12:00 PM',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a time slot';
                    }
                    return null;
                  },
                )
              else if (_isLoadingTimeSlots)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Loading available time slots...'),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedTimeSlot,
                  decoration: InputDecoration(
                    labelText: 'Time Slot',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                  ),
                  items: _availableTimeSlots.map((slot) {
                    return DropdownMenuItem<String>(
                      value: slot,
                      child: Text(slot),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeSlot = value;
                      _timeSlotController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a time slot';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Area/Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an area/address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final timeSlot = _selectedTimeSlot ?? _timeSlotController.text.trim();
                        Navigator.of(context).pop({
                          'date': _dateController.text.trim(),
                          'timeSlot': timeSlot,
                          'area': _areaController.text.trim(),
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
