import 'dart:developer';

class CategoryModel {

  final int id;
  final String categoryName;
  final String prodName;
  final String imgUrl;

  CategoryModel({required this.id, required this.categoryName, required this.imgUrl, required this.prodName});

  factory CategoryModel.fromJson(Map<String, dynamic> json){
    log("IN CATEGORY PARSING");
    return CategoryModel(
      id:json['id'],
      categoryName: json['categoryName'],
      imgUrl: json['imgUrl'],
      prodName: json['prodName']
      );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'imgUrl': imgUrl,
      'prodName': prodName,
    };
  }

}