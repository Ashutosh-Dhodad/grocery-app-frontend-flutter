import 'package:ecommerce/UserPanel/Model/CartItemModel.dart';

class CartModel {
  final int id;
  final List<CartItemModel> items;

  CartModel({ required this.id, required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<CartItemModel> itemsList = list.map((i) => CartItemModel.fromJson(i)).toList();

    return CartModel(
      id: json['id'],
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}