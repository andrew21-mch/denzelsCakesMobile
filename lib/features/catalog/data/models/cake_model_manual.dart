class CakeSize {
  final String name;
  final double multiplier;
  final double? basePriceOverride;

  const CakeSize({
    required this.name,
    required this.multiplier,
    this.basePriceOverride,
  });

  factory CakeSize.fromJson(Map<String, dynamic> json) {
    return CakeSize(
      name: json['name']?.toString() ?? '',
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      basePriceOverride: (json['basePriceOverride'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'multiplier': multiplier,
        'basePriceOverride': basePriceOverride,
      };
}

class CakeStyle {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double basePrice;
  final List<CakeSize> sizes;
  final List<String> flavors;
  final List<String> tags;
  final int prepTimeMinutes;
  final int servingsEstimate;
  final bool isAvailable;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CakeStyle({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.basePrice,
    required this.sizes,
    required this.flavors,
    required this.tags,
    required this.prepTimeMinutes,
    required this.servingsEstimate,
    required this.isAvailable,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory CakeStyle.fromJson(Map<String, dynamic> json) {
    try {
      return CakeStyle(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        images:
            (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
        basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
        sizes: (json['sizes'] as List?)
                ?.map((e) => CakeSize.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        flavors:
            (json['flavors'] as List?)?.map((e) => e.toString()).toList() ?? [],
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
        servingsEstimate: (json['servingsEstimate'] as num?)?.toInt() ?? 1,
        isAvailable: json['isAvailable'] == true,
        metadata: json['metadata'] as Map<String, dynamic>?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );
    } catch (e) {
// print('ERROR parsing CakeStyle: $e');
// print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'images': images,
        'basePrice': basePrice,
        'sizes': sizes.map((e) => e.toJson()).toList(),
        'flavors': flavors,
        'tags': tags,
        'prepTimeMinutes': prepTimeMinutes,
        'servingsEstimate': servingsEstimate,
        'isAvailable': isAvailable,
        'metadata': metadata,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  // Helper method to get price with size
  double getPriceWithSize(String sizeName) {
    final size = sizes.firstWhere(
      (s) => s.name == sizeName,
      orElse: () => sizes.first,
    );
    return size.basePriceOverride ?? (basePrice * size.multiplier);
  }

  // Helper method to get formatted price in XAF
  String getFormattedPrice(String sizeName) {
    final price = getPriceWithSize(sizeName);
    return '${price.toInt()} XAF';
  }

  // Helper method to get estimated prep time in hours
  double get prepTimeHours => prepTimeMinutes / 60.0;

  // Helper method to get prep time display string
  String get prepTimeDisplay {
    if (prepTimeMinutes < 60) {
      return '$prepTimeMinutes minutes';
    } else if (prepTimeMinutes < 1440) {
      final hours = (prepTimeMinutes / 60).round();
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final days = (prepTimeMinutes / 1440).round();
      return '$days day${days > 1 ? 's' : ''}';
    }
  }

  @override
  String toString() {
    return 'CakeStyle(id: $id, title: $title, basePrice: $basePrice, isAvailable: $isAvailable)';
  }
}

class CakeListResponse {
  final List<CakeStyle> data;
  final PaginationMeta? pagination;

  const CakeListResponse({
    required this.data,
    this.pagination,
  });

  factory CakeListResponse.fromJson(Map<String, dynamic> json) {
    return CakeListResponse(
      data: (json['data'] as List?)
              ?.map((e) => CakeStyle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
        'pagination': pagination?.toJson(),
      };
}

class CakeDetailResponse {
  final CakeStyle data;

  const CakeDetailResponse({
    required this.data,
  });

  factory CakeDetailResponse.fromJson(Map<String, dynamic> json) {
    return CakeDetailResponse(
      data: CakeStyle.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.toJson(),
      };
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
      pages: (json['pages'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'pages': pages,
      };
}
