class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final List<Address> addresses;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.addresses = const [],
    this.isEmailVerified,
    this.isPhoneVerified,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'customer',
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((addr) => Address.fromJson(addr as Map<String, dynamic>))
              .toList() ??
          [],
      isEmailVerified: json['isEmailVerified'] as bool?,
      isPhoneVerified: json['isPhoneVerified'] as bool?,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      if (isEmailVerified != null) 'isEmailVerified': isEmailVerified,
      if (isPhoneVerified != null) 'isPhoneVerified': isPhoneVerified,
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    List<Address>? addresses,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      addresses: addresses ?? this.addresses,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Address {
  final String? id;
  final String type;
  final String street;
  final String city;
  final String? state; // Made optional
  final String? zipCode; // Made optional
  final String? country; // Made optional
  final bool isDefault;

  const Address({
    this.id,
    required this.type,
    required this.street,
    required this.city,
    this.state, // Made optional
    this.zipCode, // Made optional
    this.country, // Made optional
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id']?.toString(),
      type: json['type']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zipCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Don't include _id for new addresses - let MongoDB generate it
      if (id != null && id!.length == 24)
        '_id': id, // Only include if it's a valid ObjectId
      'type': type,
      'street': street,
      'city': city,
      if (state != null && state!.isNotEmpty) 'state': state,
      if (zipCode != null && zipCode!.isNotEmpty) 'zipCode': zipCode,
      if (country != null && country!.isNotEmpty) 'country': country,
      'isDefault': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? type,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      type: type ?? this.type,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress {
    return '$street, $city, $state $zipCode, $country';
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class AuthResponse {
  final User user;
  final AuthTokens tokens;

  const AuthResponse({
    required this.user,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}
