import 'dart:developer';

import 'package:ecommerce/UserPanel/Model/ProductModel.dart';
import 'package:flutter/material.dart';
import '../Service/ProductService.dart';

class ProductController with ChangeNotifier {
  final ProductService productService = ProductService();
  Map<String, List<ProductModel>>  _products = {};
  bool _isLoading = false;

  ProductModel? _selectedProduct;
  ProductModel? get selectedProduct => _selectedProduct;

  Map<String, List<ProductModel>> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await productService.fetchProducts();
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedProduct(ProductModel product) {
    _selectedProduct = product;
    log('Selected product: ${product.name}');
    notifyListeners();
  }
}