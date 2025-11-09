class VendorPayout {
  final String id;
  final String payoutReference;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int grossAmount;
  final int? deductions;
  final int netAmount;
  final String status; // pending|processed|failed|completed
  final String paymentMethod;
  final DateTime? processedAt;
  final String? utrNumber;

  VendorPayout({
    required this.id,
    required this.payoutReference,
    this.periodStart,
    this.periodEnd,
    required this.grossAmount,
    this.deductions,
    required this.netAmount,
    required this.status,
    required this.paymentMethod,
    this.processedAt,
    this.utrNumber,
  });

  factory VendorPayout.fromJson(Map<String, dynamic> json) {
    return VendorPayout(
      id: json['id'] as String,
      payoutReference: json['payout_reference'] as String,
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'] as String)
          : null,
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'] as String)
          : null,
      grossAmount: json['gross_amount'] as int,
      deductions: json['deductions'] as int?,
      netAmount: json['net_amount'] as int,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      utrNumber: json['utr_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payout_reference': payoutReference,
      if (periodStart != null) 'period_start': periodStart!.toIso8601String(),
      if (periodEnd != null) 'period_end': periodEnd!.toIso8601String(),
      'gross_amount': grossAmount,
      if (deductions != null) 'deductions': deductions,
      'net_amount': netAmount,
      'status': status,
      'payment_method': paymentMethod,
      if (processedAt != null) 'processed_at': processedAt!.toIso8601String(),
      if (utrNumber != null) 'utr_number': utrNumber,
    };
  }

  bool get isPending => status == 'pending';
  bool get isProcessed => status == 'processed';
  bool get isFailed => status == 'failed';
  bool get isCompleted => status == 'completed';
}
