import 'dart:developer';

import 'package:ecommerce/UserPanel/Model/CategoryModel.dart';
import 'package:ecommerce/UserPanel/Service/CategoryService.dart';
import 'package:flutter/material.dart';

class CategoryController with ChangeNotifier {

  final CategoryService categoryService = CategoryService();
  Map<String, List<CategoryModel>>  _products = {};
  bool _isLoading = false;

  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;


  Map<String, List<CategoryModel>> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await categoryService.getAllCategories;
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(CategoryModel category) {
    _selectedCategory = category;
    log('Selected product: ${category.categoryName}');
    notifyListeners();
  }
}