import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'package:ecommerce/UserPanel/Model/CategoriesProductModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  final String baseUrl = "http://192.168.35.151:8081/admin";

  /// 📌 Common function to send GET requests with Authorization Header
  Future<http.Response> _getRequest(String endpoint) async {
    log("Fetching data from $baseUrl$endpoint");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt') ?? '';

    
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Authorization": "Bearer $token", // Send JWT Token
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 401) {
      throw Exception("Unauthorized: Invalid Token");
    }

    return response;
  }

  /// 📌 Fetch Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _getRequest("/stats");
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load stats");
    }
  }

 Future<void> markOrderAsShifted(String orderId) async {
  final prefs = await SharedPreferences.getInstance();
  token = prefs.getString('jwt') ?? '';

  if (token.isEmpty) {
    print("❌ Token is empty! Make sure user is logged in.");
    return;
  }

  final url = Uri.parse(
      "http://192.168.35.151:8081/orders/$orderId/status?status=Shifted for Delivery");

  final response = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    // Remove the body completely, since backend doesn't expect it
  );

  if (response.statusCode != 200) {
    log("❌ Failed to update order status: ${response.body}");
    throw Exception("Failed to update order status");
  } else {
    print("✅ Order marked as Shifted for Delivery");
  }
}



  /// 📌 Fetch Recent Orders
  Future<List<dynamic>> getRecentOrders() async {
    final response = await _getRequest("/recent-orders");
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load recent orders");
    }
  }

  /// 📌 Fetch Best-Selling Products
  Future<List<dynamic>> getBestSellingProducts() async {
    final response = await _getRequest("/best-selling-products");
    log("best celling prod: ${response.body}");
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load top products");
    }
  }
    String token = '';

  Future<void> addCategory(Map<String, List<Map<String, dynamic>>> categoryData) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwt') ?? '';

    if (token.isEmpty) {
      print("❌ Token is empty! Make sure user is logged in.");
      return;
    }

    final response = await http.post(
      Uri.parse("http://192.168.35.151:8081/api/categories/post"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(categoryData),
    );

    if (response.statusCode == 201) {
      print("✅ Category Added Successfully");
    } else {
      print("❌ Failed to Add Category: ${response.body}");
    }
  }


  /// **🚀 POST: Add Product**
  Future<void> addProduct(CategoriesProductModel product) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? '';

    if (token.isEmpty) {
      print("❌ Token is missing! User might be logged out.");
      return;
    }

    final response = await http.post(
      Uri.parse("http://192.168.35.151:8081/api/products/add/${product.category}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      print("✅ Product Added Successfully");
    } else {
      print("❌ Failed to Add Product: ${response.body}");
    }
  }


Future<bool> deleteProduct(int productId) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt'); // Fetch token before request

  if (token == null || token.isEmpty) {
    print("❌ Token is missing!");
    return false;
  }

  log("Deleting Product with ID: $productId");
  log("Using Token: $token");

  final response = await http.delete(
    Uri.parse("http://192.168.35.151:8081/api/products/delete/$productId"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  log("Response: ${response.statusCode} - ${response.body}");

  if (response.statusCode == 204) {
    print("✅ Product Deleted Successfully");
    return true;
  } else {
    print("❌ Failed to Delete Product: ${response.body}");
    return false;
   
  }
}


Future<void> updateProduct(int productId, CategoriesProductModel updatedProduct) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt'); // Fetch JWT token

  if (token == null || token.isEmpty) {
    print("❌ No valid token found!");
    return;
  }

  final url = Uri.parse("http://192.168.35.151:8081/api/products/update/$productId");

  final response = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: json.encode(updatedProduct.toJson()), // Convert model to JSON
  );

  if (response.statusCode == 200) {
    print("✅ Product Updated Successfully");
  } else {
    print("❌ Failed to Update Product: ${response.body}");
    throw Exception("Failed to update product");
  }
}

Future<List<dynamic>> getAllUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt') ?? '';

  final response = await http.get(
    Uri.parse('http://192.168.35.151:8081/api/users/all'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    log("❌ Failed to fetch users: ${response.body}");
    throw Exception('Failed to fetch users');
  }
}



}
