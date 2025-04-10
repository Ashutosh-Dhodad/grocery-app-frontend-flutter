import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  final String baseUrl = 'http://192.168.35.151:8081/orders';

  Future<void> buyProduct(int userId, int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt') ?? '';

    final uri = Uri.parse('$baseUrl/buy?userId=$userId&productId=$productId');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to place order (${res.statusCode})');
    }
  }
}
