import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/time_slot.dart';

class TimeSlotSelector extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final TimeSlot? selectedTimeSlot;
  final Function(TimeSlot) onTimeSlotSelected;

  const TimeSlotSelector({
    super.key,
    required this.timeSlots,
    this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (timeSlots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: timeSlots.map((slot) {
        final isSelected = selectedTimeSlot?.id == slot.id;
        return InkWell(
          onTap: slot.isAvailable
              ? () => onTimeSlotSelected(slot)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue
                  : (slot.isAvailable
                      ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                      : (isDark ? Colors.grey[900] : Colors.grey[200])),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryBlue
                    : (slot.isAvailable
                        ? (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                        : (isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              slot.time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : (slot.isAvailable
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.grey[600] : Colors.grey[400])),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
