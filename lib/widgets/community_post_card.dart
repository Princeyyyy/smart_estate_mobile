import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CommunityPostCard extends StatelessWidget {
  final String userName;
  final String userHandle;
  final String content;
  final List<String> imageUrls;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final String timeAgo;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const CommunityPostCard({
    super.key,
    required this.userName,
    required this.userHandle,
    required this.content,
    required this.imageUrls,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.timeAgo,
    required this.onLike,
    required this.onComment,
    required this.onShare,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.borderLight,
                child: Icon(Icons.person, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      userHandle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Images
          if (imageUrls.isNotEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.borderLight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageGrid(),
              ),
            ),

          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.favorite_outline,
                label: likesCount.toString(),
                onTap: onLike,
              ),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: commentsCount.toString(),
                onTap: onComment,
              ),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: sharesCount.toString(),
                onTap: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    if (imageUrls.isEmpty) return const SizedBox();

    if (imageUrls.length == 1) {
      return Container(
        width: double.infinity,
        height: 200,
        color: AppColors.borderLight,
        child: const Icon(
          Icons.image,
          size: 48,
          color: AppColors.textSecondary,
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: imageUrls.length > 4 ? 4 : imageUrls.length,
      itemBuilder: (context, index) {
        return Container(
          color: AppColors.borderLight,
          child: const Center(
            child: Icon(Icons.image, size: 32, color: AppColors.textSecondary),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
