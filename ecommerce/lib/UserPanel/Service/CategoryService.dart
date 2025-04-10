import 'dart:convert';
import 'dart:developer';

import 'package:ecommerce/UserPanel/Model/CategoriesProductModel.dart';
import 'package:ecommerce/UserPanel/Model/CategoryModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class CategoryService {
  Map<String, List<CategoryModel>> categories = {};

  Map<String, List<CategoryModel>> get getAllCategories => categories;
  final String baseUrl = "http://192.168.35.151:8081";

 Future<void> fetchCategoris() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt') ?? '';

  if (token.isEmpty) {
    throw Exception('Token not found');
  }

  final response = await http.get(
    Uri.parse("$baseUrl/api/categories/get"),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  log("STATUS CODE: ${response.statusCode}");
  log("RESPONSE BODY: ${response.body}");

 if (response.statusCode == 200) {
  try {
    log("Response Body: ${response.body}");
    
    // Decode response as Map<String, dynamic>
    Map<String, dynamic> data = json.decode(response.body);
    log("Decoded data: $data");

    // Grouped categories by categoryName
    Map<String, List<CategoryModel>> groupedCategories = {};

    // Iterate over the map to group categories
    data.forEach((categoryName, categoryList) {
      List<CategoryModel> categoryModels = [];

      for (var category in categoryList) {
        try {
          // Parse each category and add to the list
          CategoryModel model = CategoryModel.fromJson(category);
          categoryModels.add(model);
        } catch (e) {
          log("Error parsing category: $e");
        }
      }

      // Add grouped categories to the map
      groupedCategories[categoryName] = categoryModels;
    });

    log("Grouped Categories: $groupedCategories");

    categories = groupedCategories; // Store grouped data
  } catch (e) {
    log("Error decoding response: $e");
  }
}
 else {
    throw Exception("Failed to load categories");
  }
}


Map<String, List<CategoriesProductModel>> categoriesProducts = {};
Map<String, List<CategoriesProductModel>> get getAllCategoriesProducts => categoriesProducts;

Future<void> fetchCategorisProducts(String category) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt') ?? '';

  if (token.isEmpty) {
    throw Exception('Token not found');
  }

  final encodedCategory = Uri.encodeComponent(category); // 👈 VERY IMPORTANT
  final url = "$baseUrl/api/products/category/$encodedCategory";
  log("👉 Final Encoded URL: $url");

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  log("STATUS CODE: ${response.statusCode}");
  log("RESPONSE BODY: ${response.body}");
  log("CATEGORY: $category");

  if (response.statusCode == 200) {
    try {
      List<dynamic> data = json.decode(response.body);
      List<CategoriesProductModel> categoryModels = data
          .map((item) => CategoriesProductModel.fromJson(item))
          .toList();

      categoriesProducts[category] = categoryModels;
      log("✅ Products for $category: ${categoriesProducts[category]}");
    } catch (e) {
      log("❌ Error decoding response: $e");
    }
  } else {
    throw Exception("❌ Failed to load category product");
  }
}



}