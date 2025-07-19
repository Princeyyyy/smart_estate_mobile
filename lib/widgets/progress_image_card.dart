import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ProgressImageCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const ProgressImageCard({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: AppColors.borderLight.withOpacity(0.3),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
