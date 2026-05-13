import 'api_service.dart';

class ContactService {
  static const String _baseUrl = '/contact';

  /// Send a contact message to the backend
  static Future<Map<String, dynamic>> sendMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final response = await ApiService.post(_baseUrl, data: {
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
    });

    return response.data;
  }
}
