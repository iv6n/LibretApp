enum OrganizationType { ranch, farm, ejido, cooperative, individual }

class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.country,
    this.locale,
    this.settings,
  });

  final String id;
  final String name;
  final OrganizationType type;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? country;
  final String? locale;
  final Map<String, dynamic>? settings;

  Organization copyWith({
    String? id,
    String? name,
    OrganizationType? type,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? country,
    String? locale,
    Map<String, dynamic>? settings,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      country: country ?? this.country,
      locale: locale ?? this.locale,
      settings: settings ?? this.settings,
    );
  }
}
