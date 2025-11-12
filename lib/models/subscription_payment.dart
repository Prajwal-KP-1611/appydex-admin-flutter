/// Subscription payment model for admin dashboard
class SubscriptionPayment {
  const SubscriptionPayment({
    required this.id,
    required this.subscriptionId,
    required this.vendorId,
    required this.planId,
    required this.amountCents,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.vendorName,
    this.planName,
    this.paymentMethod,
    this.paymentMethodDetails,
    this.description,
    this.invoiceId,
    this.invoiceUrl,
    this.succeededAt,
    this.failedAt,
    this.refundedAt,
    this.metadata,
  });

  final String id;
  final int subscriptionId;
  final int vendorId;
  final String? vendorName;
  final int planId;
  final String? planName;
  final int amountCents;
  final String currency;
  final String status; // 'succeeded', 'failed', 'pending', 'refunded'
  final String? paymentMethod;
  final Map<String, dynamic>? paymentMethodDetails;
  final String? description;
  final String? invoiceId;
  final String? invoiceUrl;
  final DateTime createdAt;
  final DateTime? succeededAt;
  final DateTime? failedAt;
  final DateTime? refundedAt;
  final Map<String, dynamic>? metadata;

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) {
    return SubscriptionPayment(
      id: json['id'] as String? ?? '',
      subscriptionId: json['subscription_id'] as int? ?? 0,
      vendorId: json['vendor_id'] as int? ?? 0,
      vendorName: json['vendor_name'] as String?,
      planId: json['plan_id'] as int? ?? 0,
      planName: json['plan_name'] as String?,
      amountCents: json['amount_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'usd',
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      paymentMethodDetails:
          json['payment_method_details'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      invoiceId: json['invoice_id'] as String?,
      invoiceUrl: json['invoice_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      succeededAt: json['succeeded_at'] != null
          ? DateTime.tryParse(json['succeeded_at'] as String)
          : null,
      failedAt: json['failed_at'] != null
          ? DateTime.tryParse(json['failed_at'] as String)
          : null,
      refundedAt: json['refunded_at'] != null
          ? DateTime.tryParse(json['refunded_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'vendor_id': vendorId,
      if (vendorName != null) 'vendor_name': vendorName,
      'plan_id': planId,
      if (planName != null) 'plan_name': planName,
      'amount_cents': amountCents,
      'currency': currency,
      'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentMethodDetails != null)
        'payment_method_details': paymentMethodDetails,
      if (description != null) 'description': description,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (invoiceUrl != null) 'invoice_url': invoiceUrl,
      'created_at': createdAt.toIso8601String(),
      if (succeededAt != null) 'succeeded_at': succeededAt!.toIso8601String(),
      if (failedAt != null) 'failed_at': failedAt!.toIso8601String(),
      if (refundedAt != null) 'refunded_at': refundedAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  bool get isSucceeded => status == 'succeeded';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
  bool get isRefunded => status == 'refunded';

  String get amountDisplay {
    final dollars = amountCents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  String get cardDisplay {
    if (paymentMethodDetails == null) return 'N/A';
    final brand = paymentMethodDetails!['brand'] as String? ?? '';
    final last4 = paymentMethodDetails!['last4'] as String? ?? '';
    if (brand.isEmpty || last4.isEmpty) return 'N/A';
    return '${brand.toUpperCase()} •••• $last4';
  }
}

/// Date range for summary statistics
class DateRange {
  const DateRange({this.start, this.end});

  final String? start;
  final String? end;

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: json['start'] as String?,
      end: json['end'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (start != null) 'start': start, if (end != null) 'end': end};
  }
}

/// Subscription payment summary statistics
/// Aligned with backend API: /api/v1/admin/subscriptions/payments/summary
class SubscriptionPaymentSummary {
  const SubscriptionPaymentSummary({
    required this.totalPayments,
    required this.succeededCount,
    required this.failedCount,
    required this.pendingCount,
    required this.refundedCount,
    required this.totalAmountCents,
    required this.totalRefundedCents,
    required this.currency,
    this.dateRange,
  });

  final int totalPayments;
  final int succeededCount;
  final int failedCount;
  final int pendingCount;
  final int refundedCount;
  final int totalAmountCents;
  final int totalRefundedCents;
  final String currency;
  final DateRange? dateRange;

  factory SubscriptionPaymentSummary.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentSummary(
      totalPayments: json['total_payments'] as int? ?? 0,
      succeededCount: json['succeeded_count'] as int? ?? 0,
      failedCount: json['failed_count'] as int? ?? 0,
      pendingCount: json['pending_count'] as int? ?? 0,
      refundedCount: json['refunded_count'] as int? ?? 0,
      totalAmountCents: json['total_amount_cents'] as int? ?? 0,
      totalRefundedCents: json['total_refunded_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'usd',
      dateRange: json['date_range'] != null
          ? DateRange.fromJson(json['date_range'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_payments': totalPayments,
      'succeeded_count': succeededCount,
      'failed_count': failedCount,
      'pending_count': pendingCount,
      'refunded_count': refundedCount,
      'total_amount_cents': totalAmountCents,
      'total_refunded_cents': totalRefundedCents,
      'currency': currency,
      if (dateRange != null) 'date_range': dateRange!.toJson(),
    };
  }

  String get totalAmountDisplay {
    final dollars = totalAmountCents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  String get totalRefundedDisplay {
    final dollars = totalRefundedCents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}
