import '../services/api_service.dart';
import '../models/country_model.dart';
import 'cache_service.dart';

class CountryService {
  static Future<List<Country>> getCountries() async {
    try {
      // Try to load from cache first
      final cachedCountries = await CacheService.getCountries();
      if (cachedCountries != null) {
        return cachedCountries.map((json) => Country.fromJson(json)).toList();
      }

      // Load from API and cache
      final response = await ApiService.get('/countries');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final countries = data.map((json) => Country.fromJson(json)).toList();
        
        // Cache the data
        await CacheService.setCountries(data);
        
        return countries;
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      // Return fallback countries if API fails
      return [
        const Country(code: 'CM', name: 'Cameroon', flag: '🇨🇲', dialCode: '+237'),
        const Country(code: 'US', name: 'United States', flag: '🇺🇸', dialCode: '+1'),
        const Country(code: 'FR', name: 'France', flag: '🇫🇷', dialCode: '+33'),
        const Country(code: 'GB', name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44'),
        const Country(code: 'DE', name: 'Germany', flag: '🇩🇪', dialCode: '+49'),
        const Country(code: 'CA', name: 'Canada', flag: '🇨🇦', dialCode: '+1'),
        const Country(code: 'NG', name: 'Nigeria', flag: '🇳🇬', dialCode: '+234'),
      ];
    }
  }

  static Future<Country?> getCountryByCode(String code) async {
    try {
      final response = await ApiService.get('/countries/${code.toUpperCase()}');
      
      if (response.statusCode == 200) {
        return Country.fromJson(response.data['data']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
