import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BookingTimeSlot extends StatelessWidget {
  final String timeSlot;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;

  const BookingTimeSlot({
    super.key,
    required this.timeSlot,
    required this.isSelected,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else if (isAvailable) {
      backgroundColor = AppColors.surface;
      textColor = AppColors.textPrimary;
      borderColor = AppColors.borderLight;
    } else {
      backgroundColor = AppColors.borderLight.withOpacity(0.5);
      textColor = AppColors.textHint;
      borderColor = AppColors.borderLight;
    }

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          timeSlot,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
