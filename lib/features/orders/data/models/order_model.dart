// Placeholder order models - will be implemented when needed
// Currently focusing on cake catalog functionality

class Address {
  final String type;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  const Address({
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.isDefault,
  });

  // TODO: Implement manual JSON parsing when orders feature is needed
  factory Address.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Order models not yet implemented');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('Order models not yet implemented');
  }
}

class OrderItem {
  // TODO: Implement when needed
}

class GuestDetails {
  // TODO: Implement when needed
}

class DeliveryDetails {
  // TODO: Implement when needed
}

class Order {
  // TODO: Implement when needed
}

class OrderListResponse {
  // TODO: Implement when needed
}

class OrderDetailResponse {
  // TODO: Implement when needed
}
