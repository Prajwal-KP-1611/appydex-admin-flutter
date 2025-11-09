class VendorAnalytics {
  final AnalyticsPeriod period;
  final PerformanceMetrics performance;
  final RevenueMetrics revenue;
  final CustomerMetrics customer;
  final ServiceMetrics service;

  VendorAnalytics({
    required this.period,
    required this.performance,
    required this.revenue,
    required this.customer,
    required this.service,
  });

  factory VendorAnalytics.fromJson(Map<String, dynamic> json) {
    return VendorAnalytics(
      period: AnalyticsPeriod.fromJson(
        json['period'] as Map<String, dynamic>? ?? {},
      ),
      performance: PerformanceMetrics.fromJson(
        json['performance'] as Map<String, dynamic>? ?? {},
      ),
      revenue: RevenueMetrics.fromJson(
        json['revenue'] as Map<String, dynamic>? ?? {},
      ),
      customer: CustomerMetrics.fromJson(
        json['customer_metrics'] as Map<String, dynamic>? ?? {},
      ),
      service: ServiceMetrics.fromJson(
        json['service_metrics'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'performance': performance.toJson(),
      'revenue': revenue.toJson(),
      'customer_metrics': customer.toJson(),
      'service_metrics': service.toJson(),
    };
  }
}

class AnalyticsPeriod {
  final String start;
  final String end;

  AnalyticsPeriod({required this.start, required this.end});

  factory AnalyticsPeriod.fromJson(Map<String, dynamic> json) {
    return AnalyticsPeriod(
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end};
  }

  DateTime? get startDate => start.isNotEmpty ? DateTime.parse(start) : null;
  DateTime? get endDate => end.isNotEmpty ? DateTime.parse(end) : null;
}

class PerformanceMetrics {
  final int totalBookings;
  final int completedBookings;
  final int? cancelledBookings;
  final double completionRate;
  final double averageRating;
  final int? totalReviews;
  final int? responseTimeAvgMinutes;
  final double? acceptanceRate;

  PerformanceMetrics({
    required this.totalBookings,
    required this.completedBookings,
    this.cancelledBookings,
    required this.completionRate,
    required this.averageRating,
    this.totalReviews,
    this.responseTimeAvgMinutes,
    this.acceptanceRate,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      totalBookings: json['total_bookings'] as int? ?? 0,
      completedBookings: json['completed_bookings'] as int? ?? 0,
      cancelledBookings: json['cancelled_bookings'] as int?,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int?,
      responseTimeAvgMinutes: json['response_time_avg_minutes'] as int?,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bookings': totalBookings,
      'completed_bookings': completedBookings,
      if (cancelledBookings != null) 'cancelled_bookings': cancelledBookings,
      'completion_rate': completionRate,
      'average_rating': averageRating,
      if (totalReviews != null) 'total_reviews': totalReviews,
      if (responseTimeAvgMinutes != null)
        'response_time_avg_minutes': responseTimeAvgMinutes,
      if (acceptanceRate != null) 'acceptance_rate': acceptanceRate,
    };
  }
}

class RevenueMetrics {
  final int totalRevenue;
  final double? growthPct;
  final int? averageBookingValue;

  RevenueMetrics({
    required this.totalRevenue,
    this.growthPct,
    this.averageBookingValue,
  });

  factory RevenueMetrics.fromJson(Map<String, dynamic> json) {
    return RevenueMetrics(
      totalRevenue: json['total_revenue'] as int? ?? 0,
      growthPct: (json['growth_pct'] as num?)?.toDouble(),
      averageBookingValue: json['average_booking_value'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      if (growthPct != null) 'growth_pct': growthPct,
      if (averageBookingValue != null)
        'average_booking_value': averageBookingValue,
    };
  }
}

class CustomerMetrics {
  final int uniqueCustomers;
  final int? repeatCustomers;
  final double? repeatRate;

  CustomerMetrics({
    required this.uniqueCustomers,
    this.repeatCustomers,
    this.repeatRate,
  });

  factory CustomerMetrics.fromJson(Map<String, dynamic> json) {
    return CustomerMetrics(
      uniqueCustomers: json['unique_customers'] as int? ?? 0,
      repeatCustomers: json['repeat_customers'] as int?,
      repeatRate: (json['repeat_rate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unique_customers': uniqueCustomers,
      if (repeatCustomers != null) 'repeat_customers': repeatCustomers,
      if (repeatRate != null) 'repeat_rate': repeatRate,
    };
  }
}

class ServiceMetrics {
  final int activeServices;
  final int? totalViews;
  final double? conversionRate;

  ServiceMetrics({
    required this.activeServices,
    this.totalViews,
    this.conversionRate,
  });

  factory ServiceMetrics.fromJson(Map<String, dynamic> json) {
    return ServiceMetrics(
      activeServices: json['active_services'] as int? ?? 0,
      totalViews: json['total_views'] as int?,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_services': activeServices,
      if (totalViews != null) 'total_views': totalViews,
      if (conversionRate != null) 'conversion_rate': conversionRate,
    };
  }
}
