class VendorLead {
  final String id;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? serviceRequested;
  final String status; // new|contacted|converted|lost
  final int? budget;
  final DateTime? eventDate;
  final String message;
  final String source; // website|app|referral
  final DateTime createdAt;
  final DateTime? lastContactedAt;
  final String? convertedToBookingId;

  VendorLead({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    this.serviceRequested,
    required this.status,
    this.budget,
    this.eventDate,
    required this.message,
    required this.source,
    required this.createdAt,
    this.lastContactedAt,
    this.convertedToBookingId,
  });

  factory VendorLead.fromJson(Map<String, dynamic> json) {
    return VendorLead(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      customerEmail: json['customer_email'] as String?,
      serviceRequested: json['service_requested'] as String?,
      status: json['status'] as String,
      budget: json['budget'] as int?,
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : null,
      message: json['message'] as String? ?? '',
      source: json['source'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastContactedAt: json['last_contacted_at'] != null
          ? DateTime.parse(json['last_contacted_at'] as String)
          : null,
      convertedToBookingId: json['converted_to_booking_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (serviceRequested != null) 'service_requested': serviceRequested,
      'status': status,
      if (budget != null) 'budget': budget,
      if (eventDate != null) 'event_date': eventDate!.toIso8601String(),
      'message': message,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      if (lastContactedAt != null)
        'last_contacted_at': lastContactedAt!.toIso8601String(),
      if (convertedToBookingId != null)
        'converted_to_booking_id': convertedToBookingId,
    };
  }

  bool get isNew => status == 'new';
  bool get isContacted => status == 'contacted';
  bool get isConverted => status == 'converted';
  bool get isLost => status == 'lost';
  bool get hasBeenContacted => lastContactedAt != null;
}

class VendorLeadSummary {
  final int total;
  final int newLeads;
  final int contacted;
  final int converted;
  final int lost;
  final double conversionRate;

  VendorLeadSummary({
    required this.total,
    required this.newLeads,
    required this.contacted,
    required this.converted,
    required this.lost,
    required this.conversionRate,
  });

  factory VendorLeadSummary.fromJson(Map<String, dynamic> json) {
    return VendorLeadSummary(
      total: json['total_leads'] as int? ?? 0,
      newLeads: json['new'] as int? ?? 0,
      contacted: json['contacted'] as int? ?? 0,
      converted: json['won'] as int? ?? json['converted'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_leads': total,
      'new': newLeads,
      'contacted': contacted,
      'won': converted,
      'lost': lost,
      'conversion_rate': conversionRate,
    };
  }
}
