import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/admin_sidebar.dart';
import '../../routes.dart';
import '../../core/api_client.dart';

/// Analytics Dashboard
/// Displays Top Searches, CTR metrics, and Export functionality
class AnalyticsDashboard extends ConsumerStatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  ConsumerState<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends ConsumerState<AnalyticsDashboard> {
  DateTimeRange? _dateRange;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AppRoute.analytics,
      title: 'Analytics Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range picker and filters
            _buildFilters(),
            const SizedBox(height: 24),

            // Top Searches section
            _buildTopSearchesSection(),
            const SizedBox(height: 24),

            // CTR metrics section
            _buildCTRMetricsSection(),
            const SizedBox(height: 24),

            // Export section
            _buildExportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date range picker
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  _dateRange == null
                      ? 'Select Date Range'
                      : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Additional filters placeholder
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedFilter,
                decoration: const InputDecoration(
                  labelText: 'Filter by',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'service', child: Text('Services')),
                  DropdownMenuItem(value: 'vendor', child: Text('Vendors')),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value);
                  // TODO: Refresh data with new filter
                },
              ),
            ),
            const SizedBox(width: 16),

            // Refresh button
            FilledButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSearchesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Searches',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchTopSearches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Endpoint not available: /admin/analytics/top_searches',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                final searches = snapshot.data ?? [];
                if (searches.isEmpty) {
                  return const Center(child: Text('No search data available'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searches.length.clamp(0, 10),
                  itemBuilder: (context, index) {
                    final item = searches[index];
                    final term = item['term'] as String? ?? '';
                    final count = item['count'] as int? ?? 0;
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(term),
                      trailing: Text('$count searches'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTopSearches() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.requestAdmin<Map<String, dynamic>>(
        '/admin/analytics/top_searches',
        queryParameters: {'limit': 10},
      );
      final data = response.data;
      if (data != null && data['searches'] is List) {
        return (data['searches'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Widget _buildCTRMetricsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Click-Through Rate (CTR)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchCTRMetrics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Endpoint not available: /admin/analytics/ctr',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                final data = snapshot.data ?? {};
                final overallCTR =
                    (data['overall_ctr'] as num?)?.toDouble() ?? 0.0;
                final impressions = data['impressions'] as int? ?? 0;
                final clicks = data['clicks'] as int? ?? 0;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCard(
                          'Overall CTR',
                          '${(overallCTR * 100).toStringAsFixed(2)}%',
                        ),
                        _buildMetricCard('Impressions', '$impressions'),
                        _buildMetricCard('Clicks', '$clicks'),
                      ],
                    ),
                    if (data['time_series'] != null) ...[
                      const SizedBox(height: 16),
                      const Text('Time series data available for charting'),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchCTRMetrics() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.requestAdmin<Map<String, dynamic>>(
        '/admin/analytics/ctr',
        queryParameters: {
          'from_date': DateTime.now()
              .subtract(const Duration(days: 30))
              .toIso8601String(),
          'to_date': DateTime.now().toIso8601String(),
        },
      );
      return response.data ?? {};
    } catch (e) {
      return {};
    }
  }

  Widget _buildExportSection() {
    // TODO: Wire to POST /admin/analytics/export with job poller
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Export analytics data as CSV. Large exports are processed as background jobs.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _exportCSV,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export to CSV'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _checkExportStatus,
                  icon: const Icon(Icons.history),
                  label: const Text('Check Export Status'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'TODO: Implement job poller to track export progress',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _refreshData();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _refreshData() {
    // TODO: Refresh all analytics data with current filters
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing analytics data...')),
    );
  }

  void _exportCSV() {
    // TODO: Call POST /admin/analytics/export
    // Start job poller to track progress
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Starting CSV export...')));
  }

  void _checkExportStatus() {
    // TODO: Show dialog with recent export jobs and their status
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export History'),
        content: const Text('TODO: Display export job history'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
