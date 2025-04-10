class ProductModel {
  final int id;
  final String url;
  final String name;
  final String description;
  final double price;

  ProductModel({
    required this.id,
    required this.url,
    required this.name,
    required this.description,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      url: json['url'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
    );
  }
}