import 'dart:developer';
import 'package:ecommerce/UserPanel/Model/CartItemModel.dart';
import 'package:flutter/material.dart';
import '../Service/CartService.dart';

class CartController with ChangeNotifier {
  final CartService cartService = CartService();
  List<CartItemModel> _cartItems = [];
  List<CartItemModel> _items = [];
  bool _isLoading = false;

  List<CartItemModel> get cartItems => _cartItems;
  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchCart(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await cartService.getCart(userId);
    } catch (e) {
      log('Error fetching cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(int userId, CartItemModel item) async {
    try {
      final existingItemIndex = _cartItems.indexWhere(
        (cartItem) => cartItem.productId == item.productId,
      );

      if (existingItemIndex != -1) {
        final existingItem = _cartItems[existingItemIndex];
        final newQuantity = existingItem.quantity + item.quantity;
        await cartService.updateItemQuantity(userId, existingItem.productId, newQuantity);
        existingItem.quantity = newQuantity;
        _items.add(existingItem);
      } else {
        await cartService.addItem(userId, item);
        _cartItems.add(item);
        _items.add(item);
      }
      log("^^^^^^^^^^^^^^^^^^^^^^^^^");
      log("${_cartItems.length}");
      notifyListeners();
    } catch (e) {
      log('Error adding item to cart: $e');
    }
  }

  Future<void> updateItemQuantity(int userId, int productId, int quantity) async {
    try {
      await cartService.updateItemQuantity(userId, productId, quantity);
      int index = _cartItems.indexWhere((cartItem) => cartItem.productId == productId);
      if (index != -1) {
        _cartItems[index].quantity = quantity;
        notifyListeners();
      }
    } catch (e) {
      log('Error updating item quantity in cart: $e');
    }
  }

  Future<void> updateItem(int userId, CartItemModel item) async {
    try {
      await cartService.updateItem(userId, item);
      int index = _cartItems.indexWhere((cartItem) => cartItem.productId == item.productId);
      if (index != -1) {
        _cartItems[index] = item;
        notifyListeners();
      }
    } catch (e) {
      log('Error updating item in cart: $e');
    }
  }

  Future<void> removeItem(int userId, int productId) async {
    try {
      await cartService.removeItem(userId, productId);
      _cartItems.removeWhere((item) => item.productId == productId);
      notifyListeners();
    } catch (e) {
      log('Error removing item from cart: $e');
    }
  }

  Future<void> clearCart(int userId) async {
    try {
      await cartService.clearCart(userId);
      _cartItems.clear();
      _items.clear();
      notifyListeners();
    } catch (e) {
      log('Error clearing cart: $e');
    }
  }
}