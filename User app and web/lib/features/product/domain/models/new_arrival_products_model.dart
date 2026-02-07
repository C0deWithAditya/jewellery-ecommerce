import 'package:hexacom_user/common/models/product_model.dart';

class NewArrivalProductsModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Product>? products;

  NewArrivalProductsModel({this.totalSize, this.limit, this.offset, this.products});

  NewArrivalProductsModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse('${json['total_size']}');
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FlashSale {
  int? id;
  String? title;
  int? status;
  String? startDate;
  String? endDate;
  String? image;
  String? createdAt;
  String? updatedAt;

  FlashSale({
    this.id,
    this.title,
    this.status,
    this.startDate,
    this.endDate,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  FlashSale.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    status = json['status'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['title'] = title;
    data['status'] = status;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
