import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final String? hintText;
  final bool enabled;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.label,
    this.icon = Icons.phone,
    this.validator,
    this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Ensure controller value doesn't include +977 prefix
    if (controller.text.startsWith('+977-')) {
      controller.text = controller.text.replaceFirst('+977-', '');
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        validator: validator,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText ?? 'XXXXXXXXXX',
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(icon, color: AppColors.primaryBlue),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text(
                  '+977-',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
