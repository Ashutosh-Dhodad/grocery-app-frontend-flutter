import 'package:ecommerce/UserPanel/Model/ProductModel.dart';

class CategoriesProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String url;
  final String category;

  CategoriesProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.url,
    required this.category,
  });

  factory CategoriesProductModel.fromJson(Map<String, dynamic> json) {
    return CategoriesProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      url: json['url'],
      category: json['category'],
    );
  }

  ProductModel toProductModel() {
    return ProductModel(
      id: this.id,
      name: this.name,
      price: this.price,
      url: this.url,
      description: this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'url': url,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'CategoriesProductModel(id: $id, name: $name, price: $price, category: $category)';
  }
}
