class FilterOptions {
  final double? minPrice;
  final double? maxPrice;
  final List<String>? tags;
  final String? sortBy;
  final String? sortOrder;
  final bool? isAvailable;

  const FilterOptions({
    this.minPrice,
    this.maxPrice,
    this.tags,
    this.sortBy,
    this.sortOrder,
    this.isAvailable,
  });

  FilterOptions copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
    bool? isAvailable,
  }) {
    return FilterOptions(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      tags: tags ?? this.tags,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (tags != null && tags!.isNotEmpty) params['tags'] = tags!.join(',');
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    if (isAvailable != null) params['isAvailable'] = isAvailable;

    return params;
  }

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        (tags != null && tags!.isNotEmpty) ||
        sortBy != null ||
        sortOrder != null ||
        isAvailable != null;
  }

  FilterOptions clear() {
    return const FilterOptions();
  }

  @override
  String toString() {
    return 'FilterOptions(minPrice: $minPrice, maxPrice: $maxPrice, tags: $tags, sortBy: $sortBy, sortOrder: $sortOrder, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterOptions &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.tags == tags &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return minPrice.hashCode ^
        maxPrice.hashCode ^
        tags.hashCode ^
        sortBy.hashCode ^
        sortOrder.hashCode ^
        isAvailable.hashCode;
  }
}

// Predefined sort options
class SortOptions {
  static const String priceAsc = 'basePrice';
  static const String priceDesc = 'basePrice';
  static const String titleAsc = 'title';
  static const String titleDesc = 'title';
  static const String newest = 'createdAt';
  static const String oldest = 'createdAt';
  static const String prepTimeAsc = 'prepTimeMinutes';
  static const String prepTimeDesc = 'prepTimeMinutes';

  static const Map<String, String> sortLabels = {
    'basePrice': 'Price',
    'title': 'Name',
    'createdAt': 'Date',
    'prepTimeMinutes': 'Prep Time',
  };

  static const Map<String, String> orderLabels = {
    'asc': 'Low to High',
    'desc': 'High to Low',
  };
}
