class VendorRevenue {
  final RevenueSummary summary;
  final List<RevenueTimeSeries> timeSeries;
  final CommissionBreakdown commissionBreakdown;

  VendorRevenue({
    required this.summary,
    required this.timeSeries,
    required this.commissionBreakdown,
  });

  factory VendorRevenue.fromJson(Map<String, dynamic> json) {
    return VendorRevenue(
      summary: RevenueSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
      timeSeries:
          (json['time_series'] as List<dynamic>?)
              ?.map(
                (e) => RevenueTimeSeries.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      commissionBreakdown: CommissionBreakdown.fromJson(
        json['commission_breakdown'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'time_series': timeSeries.map((e) => e.toJson()).toList(),
      'commission_breakdown': commissionBreakdown.toJson(),
    };
  }
}

class RevenueSummary {
  // Backend returns: total_revenue, commission, net_payout, booking_count, average_booking_value
  final double totalRevenue;
  final double commission;
  final double netPayout;
  final int bookingCount;
  final double averageBookingValue;

  // Keep old fields for backward compatibility
  final int? totalBookingsValue;
  final int? platformCommission;
  final int? vendorEarnings;
  final int? taxDeducted;
  final int? netPayable;
  final int? paidAmount;
  final int? pendingPayout;

  RevenueSummary({
    required this.totalRevenue,
    required this.commission,
    required this.netPayout,
    required this.bookingCount,
    required this.averageBookingValue,
    this.totalBookingsValue,
    this.platformCommission,
    this.vendorEarnings,
    this.taxDeducted,
    this.netPayable,
    this.paidAmount,
    this.pendingPayout,
  });

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
      netPayout: (json['net_payout'] as num?)?.toDouble() ?? 0.0,
      bookingCount: json['booking_count'] as int? ?? 0,
      averageBookingValue:
          (json['average_booking_value'] as num?)?.toDouble() ?? 0.0,
      // Old fields (for backward compatibility)
      totalBookingsValue: json['total_bookings_value'] as int?,
      platformCommission: json['platform_commission'] as int?,
      vendorEarnings: json['vendor_earnings'] as int?,
      taxDeducted: json['tax_deducted'] as int?,
      netPayable: json['net_payable'] as int?,
      paidAmount: json['paid_amount'] as int?,
      pendingPayout: json['pending_payout'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'commission': commission,
      'net_payout': netPayout,
      'booking_count': bookingCount,
      'average_booking_value': averageBookingValue,
      if (totalBookingsValue != null)
        'total_bookings_value': totalBookingsValue,
      if (platformCommission != null) 'platform_commission': platformCommission,
      if (vendorEarnings != null) 'vendor_earnings': vendorEarnings,
      if (taxDeducted != null) 'tax_deducted': taxDeducted,
      if (netPayable != null) 'net_payable': netPayable,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (pendingPayout != null) 'pending_payout': pendingPayout,
    };
  }
}

class RevenueTimeSeries {
  final String date;
  final int bookings;
  final int revenue;
  final int commission;

  RevenueTimeSeries({
    required this.date,
    required this.bookings,
    required this.revenue,
    required this.commission,
  });

  factory RevenueTimeSeries.fromJson(Map<String, dynamic> json) {
    return RevenueTimeSeries(
      date: json['date'] as String,
      bookings: json['bookings'] as int? ?? 0,
      revenue: json['revenue'] as int? ?? 0,
      commission: json['commission'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'bookings': bookings,
      'revenue': revenue,
      'commission': commission,
    };
  }

  DateTime get dateTime => DateTime.parse(date);
}

class CommissionBreakdown {
  // Backend returns: platform_commission_rate, platform_commission, vendor_earnings
  final double platformCommissionRate;
  final double platformCommission;
  final double vendorEarnings;

  // Keep old fields for backward compatibility
  final double? baseCommissionRate;
  final int? totalCommission;
  final int? promotionalDiscounts;
  final int? netCommission;

  CommissionBreakdown({
    required this.platformCommissionRate,
    required this.platformCommission,
    required this.vendorEarnings,
    this.baseCommissionRate,
    this.totalCommission,
    this.promotionalDiscounts,
    this.netCommission,
  });

  factory CommissionBreakdown.fromJson(Map<String, dynamic> json) {
    return CommissionBreakdown(
      platformCommissionRate:
          (json['platform_commission_rate'] as num?)?.toDouble() ?? 0.0,
      platformCommission:
          (json['platform_commission'] as num?)?.toDouble() ?? 0.0,
      vendorEarnings: (json['vendor_earnings'] as num?)?.toDouble() ?? 0.0,
      // Old fields (for backward compatibility)
      baseCommissionRate: (json['base_commission_rate'] as num?)?.toDouble(),
      totalCommission: json['total_commission'] as int?,
      promotionalDiscounts: json['promotional_discounts'] as int?,
      netCommission: json['net_commission'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform_commission_rate': platformCommissionRate,
      'platform_commission': platformCommission,
      'vendor_earnings': vendorEarnings,
      if (baseCommissionRate != null)
        'base_commission_rate': baseCommissionRate,
      if (totalCommission != null) 'total_commission': totalCommission,
      if (promotionalDiscounts != null)
        'promotional_discounts': promotionalDiscounts,
      if (netCommission != null) 'net_commission': netCommission,
    };
  }
}
