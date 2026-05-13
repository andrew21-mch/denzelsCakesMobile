import 'package:flutter/material.dart';

class PaymentMethodModel {
  final String id;
  final String type; // 'card', 'momo', etc.
  final String displayName;
  final String? lastFourDigits; // For cards
  final String? phoneNumber; // For MOMO
  final String? brand; // Visa, Mastercard, etc.
  final bool isDefault;
  final DateTime? expiryDate;
  final DateTime createdAt;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.displayName,
    this.lastFourDigits,
    this.phoneNumber,
    this.brand,
    required this.isDefault,
    this.expiryDate,
    required this.createdAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    // Handle different field mappings for demo vs backend data
    String? lastFour;
    String? phone;
    String? cardBrand;
    String displayName = '';

    // Extract last four digits from different possible fields
    if (json['lastFourDigits'] != null) {
      lastFour = json['lastFourDigits'].toString();
    } else if (json['lastFour'] != null) {
      lastFour = json['lastFour'].toString();
    }

    // Extract phone number
    if (json['phoneNumber'] != null) {
      phone = json['phoneNumber'].toString();
    }

    // Extract card brand/type
    if (json['brand'] != null) {
      cardBrand = json['brand'].toString();
    } else if (json['cardType'] != null) {
      cardBrand = json['cardType'].toString();
    }

    // Generate display name
    if (json['displayName'] != null) {
      displayName = json['displayName'].toString();
    } else {
      // Generate display name based on type
      final type = json['type']?.toString() ?? '';
      switch (type.toLowerCase()) {
        case 'card':
          final brandText =
              cardBrand != null ? '${cardBrand.toUpperCase()} ' : '';
          final digitsText = lastFour != null ? '••••$lastFour' : '';
          displayName = '$brandText$digitsText';
          break;
        case 'mobile_money':
          if (json['provider'] != null) {
            displayName = json['provider'].toString();
          } else {
            displayName = 'Mobile Money';
          }
          break;
        default:
          displayName = type;
      }
    }

    // Handle expiry date from multiple formats
    DateTime? expiry;
    if (json['expiryDate'] != null) {
      expiry = DateTime.tryParse(json['expiryDate'].toString());
    } else if (json['expiryMonth'] != null && json['expiryYear'] != null) {
      try {
        final month = int.parse(json['expiryMonth'].toString());
        final year = int.parse(json['expiryYear'].toString());
        // Handle 2-digit years
        final fullYear = year < 100 ? 2000 + year : year;
        expiry = DateTime(fullYear, month);
      } catch (e) {
// print('DEBUG: Error parsing expiry date: $e');
      }
    }

    return PaymentMethodModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      displayName: displayName,
      lastFourDigits: lastFour,
      phoneNumber: phone,
      brand: cardBrand,
      isDefault: json['isDefault'] as bool? ?? false,
      expiryDate: expiry,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'displayName': displayName,
      if (lastFourDigits != null) 'lastFourDigits': lastFourDigits,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (brand != null) 'brand': brand,
      'isDefault': isDefault,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedDisplay {
    switch (type.toLowerCase()) {
      case 'card':
        final brandText = brand != null ? '${brand!.toUpperCase()} ' : '';
        final digitsText = lastFourDigits != null ? '••••$lastFourDigits' : '';
        return '$brandText$digitsText';
      case 'momo':
      case 'mobile_money':
        if (displayName.isNotEmpty && displayName != 'mobile_money') {
          return displayName;
        }
        return phoneNumber != null ? 'MOMO ${phoneNumber!}' : 'Mobile Money';
      default:
        return displayName.isNotEmpty ? displayName : type;
    }
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'card':
        return Icons.credit_card;
      case 'momo':
      case 'mobile_money':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }
}
