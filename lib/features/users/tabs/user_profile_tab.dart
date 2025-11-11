import 'package:flutter/material.dart';
import '../../../models/end_user_enhanced.dart';

/// Profile tab showing user information, trust score, and risk indicators
class UserProfileTab extends StatelessWidget {
  const UserProfileTab({required this.user, required this.userId, super.key});

  final EndUserEnhanced user;
  final int userId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information
          _buildPersonalInfoCard(),
          const SizedBox(height: 16),

          // Contact Information
          _buildContactInfoCard(),
          const SizedBox(height: 16),

          // Trust Score Section
          _buildTrustScoreCard(),
          const SizedBox(height: 16),

          // Activity Summary
          _buildActivitySummaryCard(),
          const SizedBox(height: 16),

          // Verification Status
          _buildVerificationCard(),
          const SizedBox(height: 16),

          // Engagement Metrics
          _buildEngagementCard(),
          const SizedBox(height: 16),

          // Risk Indicators
          _buildRiskIndicatorsCard(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', user.name ?? '—'),
            _buildInfoRow('User ID', '#${user.id}'),
            _buildInfoRow('Status', user.accountStatus ?? 'active'),
            _buildInfoRow('Joined', _formatDate(user.createdAt)),
            if (user.lastLoginAt != null)
              _buildInfoRow('Last Login', _formatDate(user.lastLoginAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Phone', user.phone ?? '—'),
            _buildInfoRow('Email', user.email),
            if (user.address != null && user.address!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Address',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(user.address!),
            ],
            if (user.city != null)
              _buildInfoRow('City', user.city!),
            if (user.state != null)
              _buildInfoRow('State', user.state!),
            if (user.pincode != null)
              _buildInfoRow('Pincode', user.pincode!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildTrustScoreCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trust Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('Trust Score: ${user.riskIndicators.trustScore}/100'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Total Bookings: ${user.activitySummary.totalBookings}'),
            Text('Completed: ${user.activitySummary.completedBookings}'),
            Text('Total Spent: ${user.activitySummary.totalSpentFormatted}'),
            Text('Reviews Given: ${user.activitySummary.totalReviews}'),
            Text('Disputes Filed: ${user.activitySummary.totalDisputes}'),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildVerificationRow(
              'Email',
              user.verification.emailVerifiedAt != null,
            ),
            _buildVerificationRow(
              'Phone',
              user.verification.phoneVerifiedAt != null,
            ),
            _buildVerificationRow(
              'Identity',
              user.verification.identityVerified,
            ),
            const SizedBox(height: 8),
            Text('Level: ${user.verification.verificationLevel}/3'),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRow(String label, bool verified) {
    return Row(
      children: [
        Icon(
          verified ? Icons.check_circle : Icons.cancel,
          color: verified ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildEngagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Engagement Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Total Logins: ${user.engagement.totalLogins}'),
            if (user.lastLoginAt != null)
              Text('Last Login: ${user.lastLoginAt.toString()}'),
            Text(
              'Days Since Registration: ${user.engagement.daysSinceRegistration}',
            ),
            Text('Level: ${user.engagement.engagementLevel}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicatorsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Indicators',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Trust Score: ${user.riskIndicators.trustScore}/100'),
            Text('Payment Failures: ${user.riskIndicators.failedPaymentCount}'),
            Text(
              'Dispute Win Rate: ${(user.riskIndicators.disputeWinRate * 100).toStringAsFixed(1)}%',
            ),
            Text(
              'High Cancellation: ${user.riskIndicators.cancellationRate > 0.3 ? "Yes" : "No"}',
            ),
            const SizedBox(height: 8),
            if (user.riskIndicators.isHighRisk)
              const Text(
                '⚠️ High Risk User',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
