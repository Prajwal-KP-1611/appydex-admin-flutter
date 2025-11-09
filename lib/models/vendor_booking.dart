class VendorBooking {
  final int id; // Backend returns integer, not string
  final String? bookingReference;
  final int? customerId;
  final String customerName;
  final int? serviceId; // Backend returns integer
  final String? serviceName;
  final String status; // pending|confirmed|completed|cancelled
  final DateTime bookingDate;
  final double amount; // Backend may return decimal
  final double? commission;
  final double? vendorPayout;
  final String paymentStatus; // pending|paid|failed
  final DateTime? createdAt;

  VendorBooking({
    required this.id,
    this.bookingReference,
    this.customerId,
    required this.customerName,
    this.serviceId,
    this.serviceName,
    required this.status,
    required this.bookingDate,
    required this.amount,
    this.commission,
    this.vendorPayout,
    required this.paymentStatus,
    this.createdAt,
  });

  factory VendorBooking.fromJson(Map<String, dynamic> json) {
    return VendorBooking(
      id: json['id'] as int,
      bookingReference: json['booking_reference'] as String?,
      customerId: json['customer_id'] as int?,
      customerName: json['customer_name'] as String? ?? '',
      serviceId: json['service_id'] as int?,
      serviceName: json['service_name'] as String?,
      status: json['status'] as String? ?? 'pending',
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'] as String)
          : DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      commission: (json['commission'] as num?)?.toDouble(),
      vendorPayout: (json['vendor_payout'] as num?)?.toDouble(),
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (bookingReference != null) 'booking_reference': bookingReference,
      if (customerId != null) 'customer_id': customerId,
      'customer_name': customerName,
      if (serviceId != null) 'service_id': serviceId,
      if (serviceName != null) 'service_name': serviceName,
      'status': status,
      'booking_date': bookingDate.toIso8601String(),
      'amount': amount,
      if (commission != null) 'commission': commission,
      if (vendorPayout != null) 'vendor_payout': vendorPayout,
      'payment_status': paymentStatus,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPaid => paymentStatus == 'paid';
}

class VendorBookingSummary {
  final int totalBookings;
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;
  final int totalRevenue;
  final int totalCommission;

  VendorBookingSummary({
    required this.totalBookings,
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
    required this.totalRevenue,
    required this.totalCommission,
  });

  factory VendorBookingSummary.fromJson(Map<String, dynamic> json) {
    return VendorBookingSummary(
      totalBookings: json['total_bookings'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      confirmed: json['confirmed'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      cancelled: json['cancelled'] as int? ?? 0,
      totalRevenue: json['total_revenue'] as int? ?? 0,
      totalCommission: json['total_commission'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bookings': totalBookings,
      'pending': pending,
      'confirmed': confirmed,
      'completed': completed,
      'cancelled': cancelled,
      'total_revenue': totalRevenue,
      'total_commission': totalCommission,
    };
  }
}
