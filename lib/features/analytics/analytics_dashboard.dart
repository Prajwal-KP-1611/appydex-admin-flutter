import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/admin_sidebar.dart';
import '../../routes.dart';

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
    // TODO: Wire to GET /admin/analytics/top_searches
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
            const Text('TODO: Display top search terms with frequency charts'),
            const SizedBox(height: 16),
            // Placeholder for chart
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Top Searches Chart Placeholder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTRMetricsSection() {
    // TODO: Wire to GET /admin/analytics/ctr
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
            const Text(
              'TODO: Display CTR metrics over time with trend analysis',
            ),
            const SizedBox(height: 16),
            // Placeholder for chart
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('CTR Metrics Chart Placeholder')),
            ),
          ],
        ),
      ),
    );
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
