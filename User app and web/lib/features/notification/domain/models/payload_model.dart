import 'dart:convert';

class PayloadModel {
  PayloadModel({
    this.title,
    this.body,
    this.orderId,
    this.image,
    this.type,
  });

  String? title;
  String? body;
  String? orderId;
  String? image;
  String? type;

  factory PayloadModel.fromRawJson(String str) => PayloadModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PayloadModel.fromJson(Map<String, dynamic> json) => PayloadModel(
    title: json["title"],
    body: json["body"],
    orderId: json["order_id"],
    image: json["image"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "body": body,
    "order_id": orderId,
    "image": image,
    "type": type,
  };
}