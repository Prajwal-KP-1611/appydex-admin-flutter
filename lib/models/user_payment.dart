/// User payment transaction
class UserPayment {
  final String id; // payment ID from gateway
  final String? bookingId;
  final int amount; // in paise
  final String paymentMethod; // upi, card, netbanking, wallet
  final String? paymentGateway; // razorpay, stripe, etc.
  final String? gatewayTransactionId;
  final String status; // success, failed, pending, refunded
  final String? failureReason;
  final int refundAmount; // in paise
  final String? refundReason;
  final DateTime createdAt;
  final DateTime? completedAt;

  const UserPayment({
    required this.id,
    this.bookingId,
    required this.amount,
    required this.paymentMethod,
    this.paymentGateway,
    this.gatewayTransactionId,
    required this.status,
    this.failureReason,
    required this.refundAmount,
    this.refundReason,
    required this.createdAt,
    this.completedAt,
  });

  factory UserPayment.fromJson(Map<String, dynamic> json) {
    return UserPayment(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String?,
      amount: json['amount'] as int,
      paymentMethod: json['payment_method'] as String? ?? 'upi',
      paymentGateway: json['payment_gateway'] as String?,
      gatewayTransactionId: json['gateway_transaction_id'] as String?,
      status: json['status'] as String,
      failureReason: json['failure_reason'] as String?,
      refundAmount: json['refund_amount'] as int? ?? 0,
      refundReason: json['refund_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_gateway': paymentGateway,
      'gateway_transaction_id': gatewayTransactionId,
      'status': status,
      'failure_reason': failureReason,
      'refund_amount': refundAmount,
      'refund_reason': refundReason,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Format amount for display
  String get amountFormatted {
    return '₹${(amount / 100).toStringAsFixed(2)}';
  }

  /// Format refund amount for display
  String get refundAmountFormatted {
    return '₹${(refundAmount / 100).toStringAsFixed(2)}';
  }

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'success':
        return 'green';
      case 'pending':
        return 'orange';
      case 'failed':
        return 'red';
      case 'refunded':
        return 'blue';
      default:
        return 'grey';
    }
  }

  /// Check if payment was successful
  bool get isSuccessful => status == 'success';

  /// Check if payment failed
  bool get isFailed => status == 'failed';

  /// Check if payment was refunded
  bool get isRefunded => refundAmount > 0;
}

/// Payment summary for user payment history
class PaymentSummary {
  final int totalPaid; // in paise
  final int totalRefunded; // in paise
  final double successRate; // 0-1
  final int failedCount;

  const PaymentSummary({
    required this.totalPaid,
    required this.totalRefunded,
    required this.successRate,
    required this.failedCount,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalPaid: json['total_paid'] as int? ?? 0,
      totalRefunded: json['total_refunded'] as int? ?? 0,
      successRate: (json['success_rate'] as num?)?.toDouble() ?? 0.0,
      failedCount: json['failed_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_paid': totalPaid,
      'total_refunded': totalRefunded,
      'success_rate': successRate,
      'failed_count': failedCount,
    };
  }

  /// Format total paid for display
  String get totalPaidFormatted {
    return '₹${(totalPaid / 100).toStringAsFixed(2)}';
  }

  /// Format total refunded for display
  String get totalRefundedFormatted {
    return '₹${(totalRefunded / 100).toStringAsFixed(2)}';
  }

  /// Get success rate as percentage
  int get successRatePercentage => (successRate * 100).round();

  /// Check if user has payment issues
  bool get hasPaymentIssues => failedCount > 0 || successRate < 0.8;
}
