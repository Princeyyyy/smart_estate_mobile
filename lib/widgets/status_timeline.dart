import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/maintenance_request.dart';

class StatusTimeline extends StatelessWidget {
  final MaintenanceStatus currentStatus;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? completedDate;

  const StatusTimeline({
    super.key,
    required this.currentStatus,
    required this.createdAt,
    this.scheduledDate,
    this.completedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimelineItem(
          title: 'Request Submitted',
          subtitle: DateFormat('MMM dd, yyyy').format(createdAt),
          isCompleted: true,
          isActive: currentStatus == MaintenanceStatus.pending,
        ),
        _buildTimelineConnector(
          isCompleted: currentStatus != MaintenanceStatus.pending,
        ),
        _buildTimelineItem(
          title: 'In Progress',
          subtitle:
              scheduledDate != null
                  ? DateFormat('MMM dd, yyyy').format(scheduledDate!)
                  : 'Pending schedule',
          isCompleted: currentStatus == MaintenanceStatus.completed,
          isActive: currentStatus == MaintenanceStatus.inProgress,
        ),
        _buildTimelineConnector(
          isCompleted: currentStatus == MaintenanceStatus.completed,
        ),
        _buildTimelineItem(
          title: 'Completed',
          subtitle:
              completedDate != null
                  ? DateFormat('MMM dd, yyyy').format(completedDate!)
                  : 'Not completed yet',
          isCompleted: currentStatus == MaintenanceStatus.completed,
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color circleColor;
    IconData? icon;

    if (isCompleted) {
      circleColor = AppColors.success;
      icon = Icons.check;
    } else if (isActive) {
      circleColor = AppColors.primary;
      icon = Icons.schedule;
    } else {
      circleColor = AppColors.borderLight;
    }

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child:
              icon != null ? Icon(icon, color: Colors.white, size: 16) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isCompleted || isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isCompleted || isActive
                          ? AppColors.textSecondary
                          : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector({required bool isCompleted}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Container(
              width: 2,
              height: 24,
              color: isCompleted ? AppColors.success : AppColors.borderLight,
            ),
          ),
        ],
      ),
    );
  }
}
