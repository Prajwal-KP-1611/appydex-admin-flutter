/// Bookings list screen with filtering and pagination
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/error_mapper.dart';
import '../../../models/booking.dart';
import '../../../providers/bookings_provider.dart';
import '../../../widgets/loading_indicator.dart';

class BookingsListScreen extends ConsumerStatefulWidget {
  const BookingsListScreen({super.key});

  @override
  ConsumerState<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends ConsumerState<BookingsListScreen> {
  final _searchController = TextEditingController();
  BookingStatus? _selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final search = _searchController.text;

    // Backend requires min 2 chars when searching
    // Skip update if 1 char to avoid unnecessary API calls
    if (search.isNotEmpty && search.length < 2) {
      return;
    }

    // Debouncing is handled by the provider
    ref.read(bookingsSearchProvider.notifier).updateSearchTerm(search);
  }

  void _applyFilters() {
    ref.read(bookingsFiltersProvider.notifier).state = BookingsFilters(
      page: 1,
      status: _selectedStatus,
      fromDate: _fromDate,
      toDate: _toDate,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _fromDate = null;
      _toDate = null;
      _searchController.clear();
    });
    ref.read(bookingsFiltersProvider.notifier).state = const BookingsFilters();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(bookingsFiltersProvider);
    final bookingsAsync = ref.watch(bookingsListProvider(filters));
    final statsAsync = ref.watch(bookingsStatsProvider);

    final canView = ref.watch(canViewBookingsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Bookings Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(bookingsListProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: !canView
          ? const Center(
              child: Text('You do not have permission to view bookings.'),
            )
          : Column(
              children: [
                // Statistics cards
                statsAsync.when(
                  data: (stats) => _buildStatsCards(stats),
                  loading: () => const SizedBox(height: 100),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Filters
                _buildFiltersBar(),

                // Bookings list
                Expanded(
                  child: bookingsAsync.when(
                    data: (response) => _buildBookingsList(response),
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, stack) => _buildErrorView(error),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCards(BookingsStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              stats.total.toString(),
              Colors.blue,
              Icons.bookmark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Pending',
              stats.pending.toString(),
              Colors.orange,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Completed',
              stats.completed.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Rate',
              '${stats.completionRate.toStringAsFixed(1)}%',
              Colors.purple,
              Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by booking number... (min 2 chars)',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '',
                  ),
                  maxLength: 64,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<BookingStatus?>(
                value: _selectedStatus,
                hint: const Text('All Status'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Status'),
                  ),
                  ...BookingStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                  _applyFilters();
                },
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  _fromDate != null && _toDate != null
                      ? '${DateFormat('MMM d').format(_fromDate!)} - ${DateFormat('MMM d').format(_toDate!)}'
                      : 'Date Range',
                ),
              ),
              if (_selectedStatus != null ||
                  _fromDate != null ||
                  _searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearFilters,
                  tooltip: 'Clear Filters',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear filters'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: response.data.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final booking = response.data[index];
              return _buildBookingCard(booking);
            },
          ),
        ),
        _buildPaginationControls(response),
      ],
    );
  }

  Widget _buildBookingCard(BookingListItem booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/bookings/detail',
            arguments: booking.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.bookingNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(booking.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('User: ${booking.user.name}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.store, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Vendor: ${booking.vendor.displayName}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Scheduled: ${DateFormat('MMM d, y - h:mm a').format(booking.scheduledAt)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created ${DateFormat('MMM d, y').format(booking.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final color = Color(int.parse(status.colorHex.replaceFirst('#', '0xFF')));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPaginationControls(response) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${response.data.length} of ${response.meta.totalItems} bookings',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: response.hasPrevPage
                    ? () {
                        ref
                            .read(bookingsFiltersProvider.notifier)
                            .update(
                              (state) =>
                                  state.copyWith(page: response.prevPage),
                            );
                      }
                    : null,
              ),
              Text(
                'Page ${response.meta.page} of ${response.meta.totalPages}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: response.hasNextPage
                    ? () {
                        ref
                            .read(bookingsFiltersProvider.notifier)
                            .update(
                              (state) =>
                                  state.copyWith(page: response.nextPage),
                            );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    final errorMessage = ErrorMapper.mapErrorToMessage(error);
    final isRetryable = ErrorMapper.isRetryable(error);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            ErrorMapper.getErrorTitle(error),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          if (isRetryable)
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(bookingsListProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
