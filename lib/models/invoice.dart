import 'package:flutter/foundation.dart';

/// Invoice model for admin panel
/// Represents platform invoices for subscriptions, bookings, etc.
@immutable
class Invoice {
  const Invoice({
    required this.id,
    required this.fullNumber,
    required this.actorType,
    required this.actorId,
    required this.grossCents,
    required this.taxRate,
    required this.taxCents,
    required this.netCents,
    required this.issuedAt,
    this.paymentEventId,
    this.vendorId,
    this.vendorName,
    this.vendorEmail,
  });

  final int id;
  final String fullNumber; // e.g., "INV-SERIES-000101"
  final String actorType; // "subscription", "booking", etc.
  final int actorId;
  final int grossCents; // Amount before tax
  final double taxRate; // e.g., 0.1 for 10%
  final int taxCents; // Tax amount
  final int netCents; // Total amount (gross + tax)
  final DateTime issuedAt;
  final int? paymentEventId;
  final int? vendorId;
  final String? vendorName;
  final String? vendorEmail;

  /// Get gross amount in dollars
  double get grossAmount => grossCents / 100.0;

  /// Get tax amount in dollars
  double get taxAmount => taxCents / 100.0;

  /// Get net amount in dollars
  double get netAmount => netCents / 100.0;

  /// Get formatted gross amount with currency
  String get formattedGross => '\$${grossAmount.toStringAsFixed(2)}';

  /// Get formatted tax amount with currency
  String get formattedTax => '\$${taxAmount.toStringAsFixed(2)}';

  /// Get formatted net amount with currency
  String get formattedNet => '\$${netAmount.toStringAsFixed(2)}';

  /// Get tax rate as percentage
  String get taxRatePercentage => '${(taxRate * 100).toStringAsFixed(1)}%';

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int? ?? 0,
      fullNumber: json['full_number'] as String? ?? '',
      actorType: json['actor_type'] as String? ?? '',
      actorId: json['actor_id'] as int? ?? 0,
      grossCents: json['gross_cents'] as int? ?? 0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      taxCents: json['tax_cents'] as int? ?? 0,
      netCents: json['net_cents'] as int? ?? 0,
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'] as String)
          : DateTime.now(),
      paymentEventId: json['payment_event_id'] as int?,
      vendorId: json['vendor_id'] as int?,
      vendorName: json['vendor_name'] as String?,
      vendorEmail: json['vendor_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_number': fullNumber,
      'actor_type': actorType,
      'actor_id': actorId,
      'gross_cents': grossCents,
      'tax_rate': taxRate,
      'tax_cents': taxCents,
      'net_cents': netCents,
      'issued_at': issuedAt.toIso8601String(),
      if (paymentEventId != null) 'payment_event_id': paymentEventId,
      if (vendorId != null) 'vendor_id': vendorId,
      if (vendorName != null) 'vendor_name': vendorName,
      if (vendorEmail != null) 'vendor_email': vendorEmail,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Invoice(id: $id, number: $fullNumber, net: $formattedNet)';
}

/// Statistics summary for invoices
@immutable
class InvoiceStats {
  const InvoiceStats({
    required this.totalInvoices,
    required this.totalRevenueCents,
    required this.totalTaxCents,
    required this.totalGrossCents,
    required this.byActorType,
  });

  final int totalInvoices;
  final int totalRevenueCents; // Net revenue (gross amount)
  final int totalTaxCents;
  final int totalGrossCents; // Total amount including tax
  final List<InvoiceStatsByActorType> byActorType;

  /// Get total revenue in dollars
  double get totalRevenue => totalRevenueCents / 100.0;

  /// Get total tax in dollars
  double get totalTax => totalTaxCents / 100.0;

  /// Get total gross in dollars
  double get totalGross => totalGrossCents / 100.0;

  /// Get formatted total revenue
  String get formattedRevenue => '\$${totalRevenue.toStringAsFixed(2)}';

  /// Get formatted total tax
  String get formattedTax => '\$${totalTax.toStringAsFixed(2)}';

  /// Get formatted total gross
  String get formattedGross => '\$${totalGross.toStringAsFixed(2)}';

  factory InvoiceStats.fromJson(Map<String, dynamic> json) {
    return InvoiceStats(
      totalInvoices: json['total_invoices'] as int? ?? 0,
      totalRevenueCents: json['total_revenue_cents'] as int? ?? 0,
      totalTaxCents: json['total_tax_cents'] as int? ?? 0,
      totalGrossCents: json['total_gross_cents'] as int? ?? 0,
      byActorType: (json['by_actor_type'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                InvoiceStatsByActorType.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_invoices': totalInvoices,
      'total_revenue_cents': totalRevenueCents,
      'total_tax_cents': totalTaxCents,
      'total_gross_cents': totalGrossCents,
      'by_actor_type': byActorType.map((item) => item.toJson()).toList(),
    };
  }
}

/// Invoice statistics broken down by actor type
@immutable
class InvoiceStatsByActorType {
  const InvoiceStatsByActorType({
    required this.actorType,
    required this.count,
    required this.revenueCents,
  });

  final String actorType; // "subscription", "booking", etc.
  final int count;
  final int revenueCents;

  /// Get revenue in dollars
  double get revenue => revenueCents / 100.0;

  /// Get formatted revenue
  String get formattedRevenue => '\$${revenue.toStringAsFixed(2)}';

  factory InvoiceStatsByActorType.fromJson(Map<String, dynamic> json) {
    return InvoiceStatsByActorType(
      actorType: json['actor_type'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      revenueCents: json['revenue_cents'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actor_type': actorType,
      'count': count,
      'revenue_cents': revenueCents,
    };
  }
}

/// Request to resend an invoice email
@immutable
class InvoiceEmailRequest {
  const InvoiceEmailRequest({this.email});

  final String? email; // Optional, defaults to vendor email

  Map<String, dynamic> toJson() {
    return {if (email != null && email!.isNotEmpty) 'email': email};
  }
}

/// Result of resending invoice email
@immutable
class InvoiceEmailResult {
  const InvoiceEmailResult({
    required this.message,
    required this.invoiceId,
    required this.email,
  });

  final String message;
  final int invoiceId;
  final String email;

  factory InvoiceEmailResult.fromJson(Map<String, dynamic> json) {
    return InvoiceEmailResult(
      message: json['message'] as String? ?? '',
      invoiceId: json['invoice_id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
    );
  }
}
