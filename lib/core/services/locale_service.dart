import 'package:flutter/material.dart';
import 'storage_service.dart';

class LocaleService {
  static const String _localeKey = 'app_locale';
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('fr', ''), // French
  ];
  
  // Default locale
  static const Locale defaultLocale = Locale('en', '');
  
  /// Get saved locale from storage
  static Future<Locale> getLocale() async {
    final localeCode = await StorageService.getString(_localeKey);
    
    if (localeCode != null) {
      return Locale(localeCode);
    }
    
    // If no saved preference, try to detect from device
    return defaultLocale;
  }
  
  /// Save locale preference
  static Future<void> setLocale(Locale locale) async {
    await StorageService.setString(_localeKey, locale.languageCode);
  }
  
  /// Get locale from language code
  static Locale getLocaleFromCode(String code) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => defaultLocale,
    );
  }
  
  /// Get language code from locale
  static String getLanguageCode(Locale locale) {
    return locale.languageCode;
  }
  
  /// Check if locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }
}

