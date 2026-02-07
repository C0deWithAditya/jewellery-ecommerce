import 'dart:convert';

import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';

class ReOrderDetailsModel {
  final List<OrderDetailsModel>? orderDetails;
  final List<Product>? products;

  ReOrderDetailsModel({
    this.orderDetails,
    this.products,
  });

  factory ReOrderDetailsModel.fromJson(String str) => ReOrderDetailsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ReOrderDetailsModel.fromMap(Map<String, dynamic> json) => ReOrderDetailsModel(
    orderDetails: json["order_details"] == null ? [] : List<OrderDetailsModel>.from(json["order_details"]!.map((x) => OrderDetailsModel.fromJson(x))),
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toMap() => {
    "order_details": orderDetails == null ? [] : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}
