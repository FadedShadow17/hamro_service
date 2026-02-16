import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_option.dart';

class ServiceOptionSelector extends StatelessWidget {
  final List<ServiceOption> serviceOptions;
  final ServiceOption? selectedOption;
  final Function(ServiceOption) onOptionSelected;

  const ServiceOptionSelector({
    super.key,
    required this.serviceOptions,
    this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: serviceOptions.map((option) {
        final isSelected = selectedOption?.id == option.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onOptionSelected(option),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey[300] : Colors.grey[800]),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white70
                                : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rs ${option.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
