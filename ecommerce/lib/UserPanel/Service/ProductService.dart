import 'dart:convert';
import 'dart:developer';
import 'package:ecommerce/UserPanel/Model/ProductModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ProductService {
  final String baseUrl = 'http://192.168.35.151:8081/api/products/all';

  Future<Map<String, List<ProductModel>>> fetchProducts() async {
  log("In fetchProducts");
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt') ?? '';

  if (token.isEmpty) {
    throw Exception('Token not found');
  }

  final response = await http.get(
    Uri.parse(baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  log(response.body);
  
  if (response.statusCode == 200) {
    Map<String, dynamic> body = jsonDecode(response.body);
    
    // Convert the Map<String, dynamic> to Map<String, List<ProductModel>>
    Map<String, List<ProductModel>> productsByCategory = {};
    
    body.forEach((category, products) {
      productsByCategory[category] = (products as List<dynamic>)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });

    return productsByCategory;
  } else {
    throw Exception('Failed to load products');
  }
}

}