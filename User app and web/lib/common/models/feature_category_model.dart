import 'dart:convert';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';

class FeatureCategoryModel {
  List<FeaturedCategory>? featuredData;

  FeatureCategoryModel({
    this.featuredData,
  });

  factory FeatureCategoryModel.fromJson(String str) => FeatureCategoryModel.fromMap(json.decode(str));


  factory FeatureCategoryModel.fromMap(Map<String, dynamic> json) => FeatureCategoryModel(
    featuredData: json["featured_data"] == null ? [] : List<FeaturedCategory>.from(json["featured_data"]!.map((x) => FeaturedCategory.fromMap(x))),
  );

}

class FeaturedCategory {
  CategoryModel? category;
  List<Product>? products;

  FeaturedCategory({
    this.category,
    this.products,
  });

  factory FeaturedCategory.fromJson(String str) => FeaturedCategory.fromMap(json.decode(str));


  factory FeaturedCategory.fromMap(Map<String, dynamic> json) => FeaturedCategory(
    category: json["category"] == null ? null : CategoryModel.fromJson(json["category"]),
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
  );

}



