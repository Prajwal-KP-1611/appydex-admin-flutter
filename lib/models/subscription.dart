class Subscription {
  Subscription({
    required this.id,
    required this.vendorId,
    required this.planCode,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.paidMonths,
  });

  final int id;
  final int vendorId;
  final String planCode;
  final String status;
  final DateTime? startAt;
  final DateTime? endAt;
  final int paidMonths;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int,
      planCode: json['plan_code'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      startAt: DateTime.tryParse(json['start_at'] as String? ?? ''),
      endAt: DateTime.tryParse(json['end_at'] as String? ?? ''),
      paidMonths: json['paid_months'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'plan_code': planCode,
      'status': status,
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'paid_months': paidMonths,
    };
  }
}
