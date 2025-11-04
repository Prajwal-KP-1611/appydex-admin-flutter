/// Model for service aligned with Admin Services API
class Service {
  const Service({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.category,
    required this.priceCents,
    required this.unit,
    required this.isActive,
    required this.createdAt,
    this.description,
    this.vendorName,
    this.updatedAt,
  });

  final int id; // Changed from String to int per API spec
  final int vendorId;
  final String? vendorName;
  final String title;
  final String? description;
  final String category;
  final int priceCents;
  final String unit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Service.fromJson(Map<String, dynamic> json) {
    // Align with API response format
    return Service(
      id: (json['id'] is String)
          ? int.tryParse(json['id'] as String) ?? 0
          : (json['id'] as int? ?? 0),
      vendorId: (json['vendor_id'] is String)
          ? int.tryParse(json['vendor_id'] as String) ?? 0
          : (json['vendor_id'] as int? ?? 0),
      vendorName:
          (json['vendor_name'] as String?) ??
          (json['vendor'] is Map<String, dynamic>
              ? (json['vendor'] as Map<String, dynamic>)['display_name']
                    as String?
              : null),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String? ?? '',
      priceCents: json['price_cents'] is String
          ? int.tryParse(json['price_cents'] as String) ?? 0
          : (json['price_cents'] as int? ?? 0),
      unit: json['unit'] as String? ?? 'unit',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      if (vendorName != null) 'vendor_name': vendorName,
      'title': title,
      if (description != null) 'description': description,
      'category': category,
      'price_cents': priceCents,
      'unit': unit,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Service copyWith({
    int? id,
    int? vendorId,
    String? vendorName,
    String? title,
    String? description,
    String? category,
    int? priceCents,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priceCents: priceCents ?? this.priceCents,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get priceDisplay => '\$${(priceCents / 100).toStringAsFixed(2)}';
}

/// Request model for creating/updating services
/// Aligned with POST /api/v1/admin/services contract
class ServiceRequest {
  const ServiceRequest({
    required this.vendorId,
    required this.title,
    required this.priceCents,
    this.description,
    this.category,
    this.unit = 'unit',
  });

  final int vendorId; // Required per API contract
  final String title;
  final String? description;
  final String? category;
  final int priceCents;
  final String unit;

  Map<String, dynamic> toJson() => {
    'vendor_id': vendorId,
    'title': title,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (category != null && category!.isNotEmpty) 'category': category,
    'price_cents': priceCents,
    'unit': unit,
  };
}

/// Category model for service categorization
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.slug,
    this.serviceCount,
    this.subcategories = const [],
  });

  final String id;
  final String name;
  final String? parentId;
  final String? slug;
  final int? serviceCount;
  final List<ServiceCategory> subcategories;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      parentId: json['parent_id']?.toString(),
      slug: json['slug'] as String?,
      serviceCount: (json['service_count'] is String)
          ? int.tryParse(json['service_count'] as String)
          : json['service_count'] as int?,
      subcategories:
          (json['subcategories'] as List<dynamic>?)
              ?.map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (subcategories.isNotEmpty)
        'subcategories': subcategories.map((e) => e.toJson()).toList(),
    };
  }
}
