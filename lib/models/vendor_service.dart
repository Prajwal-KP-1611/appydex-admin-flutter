class VendorService {
  final String id;
  final int vendorId;
  final String name;
  final String category;
  final String? subcategory;
  final String status; // active|inactive|pending_approval
  final ServicePricing pricing;
  final bool isFeatured;
  final int? viewsCount;
  final int? bookingsCount;
  final double? rating;
  final DateTime createdAt;

  VendorService({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.category,
    this.subcategory,
    required this.status,
    required this.pricing,
    required this.isFeatured,
    this.viewsCount,
    this.bookingsCount,
    this.rating,
    required this.createdAt,
  });

  factory VendorService.fromJson(Map<String, dynamic> json) {
    // Backend returns 'title', not 'name'
    final serviceName =
        json['title'] as String? ?? json['name'] as String? ?? '';

    // Backend returns simple 'price' integer, not nested 'pricing' object
    final price = json['price'] as int? ?? 0;
    final pricing = json['pricing'] != null
        ? ServicePricing.fromJson(json['pricing'] as Map<String, dynamic>)
        : ServicePricing(
            basePrice: price,
            currency: 'INR',
            pricingType: 'fixed',
          );

    return VendorService(
      id: (json['id'] ?? 0).toString(),
      vendorId: json['vendor_id'] as int? ?? 0,
      name: serviceName,
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String?,
      status: (json['is_active'] as bool? ?? true) ? 'active' : 'inactive',
      pricing: pricing,
      isFeatured: json['is_featured'] as bool? ?? false,
      viewsCount: json['views_count'] as int?,
      bookingsCount: json['bookings_count'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'name': name,
      'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      'status': status,
      'pricing': pricing.toJson(),
      'is_featured': isFeatured,
      if (viewsCount != null) 'views_count': viewsCount,
      if (bookingsCount != null) 'bookings_count': bookingsCount,
      if (rating != null) 'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isPendingApproval => status == 'pending_approval';
}

class ServicePricing {
  final int basePrice;
  final String currency;
  final String pricingType; // per_hour, per_day, fixed, etc.

  ServicePricing({
    required this.basePrice,
    required this.currency,
    required this.pricingType,
  });

  factory ServicePricing.fromJson(Map<String, dynamic> json) {
    return ServicePricing(
      basePrice: json['base_price'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      pricingType: json['pricing_type'] as String? ?? 'fixed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_price': basePrice,
      'currency': currency,
      'pricing_type': pricingType,
    };
  }

  String get formattedPrice {
    // Format price in INR with commas
    final formatter = basePrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$currency $formatter';
  }
}
