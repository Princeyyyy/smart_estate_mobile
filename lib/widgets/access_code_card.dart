import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';

class AccessCodeCard extends StatelessWidget {
  final String code;
  final String visitorName;
  final String purpose;
  final DateTime validUntil;
  final bool isActive;
  final VoidCallback? onShare;
  final VoidCallback? onRevoke;

  const AccessCodeCard({
    super.key,
    required this.code,
    required this.visitorName,
    required this.purpose,
    required this.validUntil,
    required this.isActive,
    this.onShare,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpired = !isActive || validUntil.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isExpired
                  ? AppColors.error.withOpacity(0.3)
                  : AppColors.success.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with code and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isExpired
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.qr_code,
                  color: isExpired ? AppColors.error : AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      isExpired ? 'Expired' : 'Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isExpired ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isExpired) ...[
                IconButton(
                  onPressed: onShare,
                  icon: const Icon(Icons.share, color: AppColors.primary),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Visitor Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Visitor: $visitorName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Purpose: $purpose',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isExpired
                          ? Icons.schedule_outlined
                          : Icons.timer_outlined,
                      size: 16,
                      color:
                          isExpired ? AppColors.error : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isExpired
                          ? 'Expired: ${DateFormat('MMM dd, HH:mm').format(validUntil)}'
                          : 'Valid until: ${DateFormat('MMM dd, HH:mm').format(validUntil)}',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isExpired
                                ? AppColors.error
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                if (!isExpired) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expires in ${_getTimeRemaining()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          if (!isExpired && (onShare != null || onRevoke != null)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onShare != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onShare,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text(
                        'Share Code',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                if (onShare != null && onRevoke != null)
                  const SizedBox(width: 12),
                if (onRevoke != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRevoke,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text(
                        'Revoke',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final difference = validUntil.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Less than 1 minute';
    }
  }
}
