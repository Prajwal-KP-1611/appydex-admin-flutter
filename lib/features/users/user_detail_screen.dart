import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/users/user_detail_providers.dart';
import 'tabs/user_profile_tab.dart';
import 'tabs/user_activity_tab.dart';
import 'tabs/user_bookings_tab.dart';
import 'tabs/user_payments_tab.dart';
import 'tabs/user_reviews_tab.dart';
import 'tabs/user_disputes_tab.dart';

/// User detail screen with comprehensive tabs for end-user management
class UserDetailScreen extends ConsumerStatefulWidget {
  const UserDetailScreen({required this.userId, super.key});

  final int userId;

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDetailAsync = ref.watch(userDetailProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: userDetailAsync.when(
          data: (user) => Row(
            children: [
              Text(user.name),
              const SizedBox(width: 12),
              _buildStatusChip(user.displayStatus),
              if (user.riskIndicators.isHighRisk) ...[
                const SizedBox(width: 8),
                _buildRiskBadge(),
              ],
            ],
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('User Details'),
        ),
        actions: [
          // Trust Score Badge
          userDetailAsync.whenOrNull(
                data: (user) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: _buildTrustScoreBadge(
                      user.riskIndicators.trustScore,
                    ),
                  ),
                ),
              ) ??
              const SizedBox.shrink(),
          // Actions Menu
          userDetailAsync.whenOrNull(data: (user) => _buildActionsMenu(user)) ??
              const SizedBox.shrink(),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Bookings'),
            Tab(icon: Icon(Icons.payment), text: 'Payments'),
            Tab(icon: Icon(Icons.star), text: 'Reviews'),
            Tab(icon: Icon(Icons.report_problem), text: 'Disputes'),
          ],
        ),
      ),
      body: userDetailAsync.when(
        data: (user) => TabBarView(
          controller: _tabController,
          children: [
            UserProfileTab(user: user, userId: widget.userId),
            UserActivityTab(userId: widget.userId),
            UserBookingsTab(userId: widget.userId),
            UserPaymentsTab(userId: widget.userId),
            UserReviewsTab(userId: widget.userId),
            UserDisputesTab(userId: widget.userId),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading user: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userDetailProvider(widget.userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      case 'inactive':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRiskBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 14, color: Colors.red),
          SizedBox(width: 4),
          Text(
            'HIGH RISK',
            style: TextStyle(
              color: Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustScoreBadge(int score) {
    Color color;
    if (score >= 70) {
      color = Colors.green;
    } else if (score >= 50) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, size: 16),
          const SizedBox(width: 6),
          Text(
            'Trust: $score/100',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(user) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'suspend':
            _showSuspendDialog();
            break;
          case 'reactivate':
            _showReactivateDialog();
            break;
          case 'force_logout':
            _showForceLogoutDialog();
            break;
          case 'update_trust_score':
            _showUpdateTrustScoreDialog();
            break;
          case 'view_full_profile':
            // Navigate to full profile view
            break;
        }
      },
      itemBuilder: (context) => [
        if (!user.isSuspended)
          const PopupMenuItem(
            value: 'suspend',
            child: ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Suspend User'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (user.isSuspended)
          const PopupMenuItem(
            value: 'reactivate',
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Reactivate User'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        const PopupMenuItem(
          value: 'force_logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Force Logout All'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'update_trust_score',
          child: ListTile(
            leading: Icon(Icons.score),
            title: Text('Update Trust Score'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'view_full_profile',
          child: ListTile(
            leading: Icon(Icons.open_in_new),
            title: Text('View Full Profile'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  void _showSuspendDialog() {
    final reasonController = TextEditingController();
    final durationController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason *',
                hintText: 'e.g., Multiple payment failures',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (days)',
                hintText: '30',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reason is required')),
                );
                return;
              }

              final duration = int.tryParse(durationController.text);

              try {
                final actions = ref.read(userActionsProvider(widget.userId));
                await actions.suspend(
                  reason: reason,
                  durationDays: duration,
                  notifyUser: true,
                  idempotencyKey: DateTime.now().millisecondsSinceEpoch
                      .toString(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User suspended successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showReactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivate User'),
        content: const Text(
          'Are you sure you want to reactivate this user? They will regain full access to the platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final actions = ref.read(userActionsProvider(widget.userId));
                await actions.reactivate(
                  notes: 'Reactivated by admin',
                  notifyUser: true,
                  idempotencyKey: DateTime.now().millisecondsSinceEpoch
                      .toString(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User reactivated successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Reactivate'),
          ),
        ],
      ),
    );
  }

  void _showForceLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Logout All Sessions'),
        content: const Text(
          'This will immediately terminate all active sessions for this user. They will need to log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final actions = ref.read(userActionsProvider(widget.userId));
                final result = await actions.forceLogoutAll(
                  idempotencyKey: DateTime.now().millisecondsSinceEpoch
                      .toString(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  final count = result['sessions_terminated'] ?? 0;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$count sessions terminated')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Force Logout'),
          ),
        ],
      ),
    );
  }

  void _showUpdateTrustScoreDialog() {
    final scoreController = TextEditingController();
    final reasonController = TextEditingController();
    bool applyRestrictions = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Trust Score'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: scoreController,
                decoration: const InputDecoration(
                  labelText: 'New Trust Score (0-100) *',
                  hintText: '75',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                  hintText: 'e.g., Manual adjustment for good behavior',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Apply Restrictions'),
                subtitle: const Text(
                  'Apply automatic restrictions based on score',
                ),
                value: applyRestrictions,
                onChanged: (value) {
                  setState(() {
                    applyRestrictions = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final scoreText = scoreController.text.trim();
                final reason = reasonController.text.trim();

                if (scoreText.isEmpty || reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }

                final score = int.tryParse(scoreText);
                if (score == null || score < 0 || score > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Score must be between 0 and 100'),
                    ),
                  );
                  return;
                }

                try {
                  final actions = ref.read(userActionsProvider(widget.userId));
                  await actions.updateTrustScore(
                    score: score,
                    reason: reason,
                    applyRestrictions: applyRestrictions,
                    idempotencyKey: DateTime.now().millisecondsSinceEpoch
                        .toString(),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trust score updated successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
