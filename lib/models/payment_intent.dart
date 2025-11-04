/// Payment Intent model
/// Represents payment transactions in the system
class PaymentIntent {
  const PaymentIntent({
    required this.id,
    required this.vendorId,
    required this.amountCents,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.vendorName,
    this.description,
    this.succeededAt,
  });

  final String id; // e.g., "pi_123abc"
  final int vendorId;
  final String? vendorName;
  final int amountCents;
  final String currency; // e.g., "USD"
  final String status; // 'succeeded', 'pending', 'failed', 'cancelled'
  final String? description;
  final DateTime createdAt;
  final DateTime? succeededAt;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id'] as int? ?? 0,
      vendorName: json['vendor_name'] as String?,
      amountCents: json['amount_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      succeededAt: json['succeeded_at'] != null
          ? DateTime.tryParse(json['succeeded_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      if (vendorName != null) 'vendor_name': vendorName,
      'amount_cents': amountCents,
      'currency': currency,
      'status': status,
      if (description != null) 'description': description,
      'created_at': createdAt.toIso8601String(),
      if (succeededAt != null) 'succeeded_at': succeededAt!.toIso8601String(),
    };
  }

  String get amountDisplay => '\$${(amountCents / 100).toStringAsFixed(2)}';

  bool get isSucceeded => status == 'succeeded';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
}
