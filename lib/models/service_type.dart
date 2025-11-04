/// Service Type (master catalog) model
/// Represents platform-wide master catalog of service categories
class ServiceType {
  const ServiceType({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.servicesCount,
  });

  final String id; // UUID
  final String name;
  final String? description;
  final DateTime? createdAt;
  final int? servicesCount;

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      servicesCount: json['services_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (servicesCount != null) 'services_count': servicesCount,
    };
  }

  ServiceType copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    int? servicesCount,
  }) {
    return ServiceType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      servicesCount: servicesCount ?? this.servicesCount,
    );
  }
}

/// Request model for creating/updating service types
class ServiceTypeRequest {
  const ServiceTypeRequest({required this.name, this.description});

  final String name;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}
