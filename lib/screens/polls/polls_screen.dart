import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';

class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final DateTime startDate;
  final DateTime endDate;
  final bool hasVoted;
  final String? userVote;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.startDate,
    required this.endDate,
    required this.hasVoted,
    this.userVote,
  });
}

class PollOption {
  final String id;
  final String text;
  final int votes;

  PollOption({required this.id, required this.text, required this.votes});
}

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Poll> _polls = [
    Poll(
      id: '1',
      question: 'Should we install solar panels on the building roof?',
      options: [
        PollOption(id: 'yes', text: 'Yes, install solar panels', votes: 45),
        PollOption(id: 'no', text: 'No, keep current system', votes: 23),
        PollOption(id: 'maybe', text: 'Need more information', votes: 12),
      ],
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      hasVoted: false,
      userVote: null,
    ),
    Poll(
      id: '2',
      question: 'What should be the new gym operating hours?',
      options: [
        PollOption(id: '6-22', text: '6:00 AM - 10:00 PM', votes: 34),
        PollOption(id: '24h', text: '24 hours', votes: 28),
        PollOption(id: '7-21', text: '7:00 AM - 9:00 PM', votes: 18),
      ],
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      hasVoted: true,
      userVote: '6-22',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Community Polls',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Results')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildActivePolls(), _buildPollResults()],
      ),
    );
  }

  Widget _buildActivePolls() {
    final activePolls =
        _polls.where((poll) => poll.endDate.isAfter(DateTime.now())).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activePolls.length,
      itemBuilder: (context, index) {
        final poll = activePolls[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              Text(
                poll.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...poll.options.map((option) => _buildPollOption(poll, option)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ends in ${_getDaysRemaining(poll.endDate)} days',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_getTotalVotes(poll)} votes',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (!poll.hasVoted) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitVote(poll.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit Vote'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPollOption(Poll poll, PollOption option) {
    final totalVotes = _getTotalVotes(poll);
    final percentage = totalVotes > 0 ? (option.votes / totalVotes) * 100 : 0.0;
    final isSelected = poll.userVote == option.id;

    return GestureDetector(
      onTap:
          poll.hasVoted
              ? null
              : () {
                // Handle option selection for voting
              },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              poll.hasVoted
                  ? AppColors.background
                  : AppColors.borderLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (!poll.hasVoted)
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color:
                        isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    size: 20,
                  ),
                if (!poll.hasVoted) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (poll.hasVoted)
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            if (poll.hasVoted) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPollResults() {
    final completedPolls =
        _polls.where((poll) => poll.endDate.isBefore(DateTime.now())).toList();

    if (completedPolls.isEmpty) {
      return const Center(
        child: Text(
          'No completed polls yet',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedPolls.length,
      itemBuilder: (context, index) {
        final poll = completedPolls[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              Text(
                poll.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ENDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...poll.options.map((option) => _buildPollOption(poll, option)),
              const SizedBox(height: 16),
              Text(
                'Total votes: ${_getTotalVotes(poll)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getTotalVotes(Poll poll) {
    return poll.options.fold(0, (sum, option) => sum + option.votes);
  }

  int _getDaysRemaining(DateTime endDate) {
    final difference = endDate.difference(DateTime.now());
    return difference.inDays;
  }

  void _submitVote(String pollId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vote submitted successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
