import 'package:flutter/material.dart';
import '../constants/colors.dart';

class DirectoryContactCard extends StatelessWidget {
  final String name;
  final String unitNumber;
  final String phone;
  final String email;
  final String role;
  final String? avatar;
  final bool isOnline;

  const DirectoryContactCard({
    super.key,
    required this.name,
    required this.unitNumber,
    required this.phone,
    required this.email,
    required this.role,
    this.avatar,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.borderLight,
                backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
                child:
                    avatar == null
                        ? const Icon(
                          Icons.person,
                          size: 28,
                          color: AppColors.textSecondary,
                        )
                        : null,
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Contact Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getRoleColor(role),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.home,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unitNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (isOnline) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Contact Actions
                Row(
                  children: [
                    _buildContactAction(
                      icon: Icons.phone,
                      onTap: () => _makeCall(phone),
                    ),
                    const SizedBox(width: 12),
                    _buildContactAction(
                      icon: Icons.email,
                      onTap: () => _sendEmail(email),
                    ),
                    const SizedBox(width: 12),
                    _buildContactAction(
                      icon: Icons.message,
                      onTap: () => _sendMessage(name),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'resident':
        return AppColors.primary;
      case 'estate manager':
        return AppColors.warning;
      case 'head of security':
        return AppColors.error;
      case 'maintenance supervisor':
        return AppColors.info;
      case 'cleaning supervisor':
        return AppColors.success;
      case 'receptionist':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  void _makeCall(String phoneNumber) {
    // TODO: Implement phone call functionality
  }

  void _sendEmail(String email) {
    // TODO: Implement email functionality
  }

  void _sendMessage(String name) {
    // TODO: Implement messaging functionality
  }
}
