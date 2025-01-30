import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://api.ornek.com'; // API URL'nizi buraya ekleyin

  static Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    final url = Uri.parse('$baseUrl/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'emailOrPhone': emailOrPhone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Giriş başarısız: ${response.reasonPhrase}');
    }
  }
}
