import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/CartItemModel.dart';

class CartService {
  final String baseUrl = 'http://192.168.35.151:8081/api/cart';

  Future<void> addItem(int userId, CartItemModel item) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/$userId/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add item to cart');
    }
  }

 Future<void> updateItemQuantity(int userId, int productId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt') ?? '';
    log("User id: $userId, Product id: $productId, Quantity: $quantity --------------------------");
    final response = await http.post(
      Uri.parse('$baseUrl/$userId/updateQuantity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item quantity in cart');
    }
  }

    Future<void> updateItem(int userId, CartItemModel item) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/$userId/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item in cart');
    }
  }

  Future<void> removeItem(int userId, int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt') ?? '';

    final response = await http.delete(
      Uri.parse('$baseUrl/$userId/remove/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item from cart');
    }
  }

  Future<void> clearCart(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt') ?? '';

    final response = await http.delete(
      Uri.parse('$baseUrl/$userId/clear'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }

  Future<List<CartItemModel>> getCart(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt') ?? '';
  log("cart token******************   $token");
  log("$userId  my id");
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/get'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Check if 'items' exists and is a list
      if (data['items'] != null && data['items'] is List) {
        List<CartItemModel> cartItems = (data['items'] as List)
            .map((item) => CartItemModel.fromJson(item))
            .toList();
        return cartItems;
      } else {
        throw Exception("Invalid response format: 'items' not found or not a list");
      }
    } else {
      throw Exception("Failed to load cart: ${response.statusCode}");
    }
  } catch (e) {
    // Log the exception
    log("Error fetching cart: $e");
    throw Exception("An error occurred while fetching the cart: $e");
  }
}

}