import 'package:hexacom_user/common/models/product_model.dart';

class OrderDetailsModel {
  int? _id;
  int? _productId;
  int? _orderId;
  double? _price;
  Product? _productDetails;
  // List<Variation> _variation;
  double? _discountOnProduct;
  String? _discountType;
  int? _quantity;
  double? _taxAmount;
  String? _createdAt;
  String? _updatedAt;
  int? _reviewCount;
  String? _variation;

  OrderDetailsModel(
      {int? id,
        int? productId,
        int? orderId,
        double? price,
        Product? productDetails,
        // List<Variation> variation,
        double? discountOnProduct,
        String? discountType,
        int? quantity,
        double? taxAmount,
        String? createdAt,
        String? updatedAt,
        String? variant,
        int? reviewCount,
        String? variation
      }) {
    _id = id;
    _productId = productId;
    _orderId = orderId;
    _price = price;
    _productDetails = productDetails;
    _variation = variation;
    _discountOnProduct = discountOnProduct;
    _discountType = discountType;
    _quantity = quantity;
    _taxAmount = taxAmount;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _reviewCount = reviewCount;
  }

  int? get id => _id;
  int? get productId => _productId;
  int? get orderId => _orderId;
  double? get price => _price;
  Product? get productDetails => _productDetails;
  String? get variation => _variation;
  double? get discountOnProduct => _discountOnProduct;
  String? get discountType => _discountType;
  int? get quantity => _quantity;
  double? get taxAmount => _taxAmount;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get reviewCount => _reviewCount;


  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _productId = json['product_id'];
    _orderId = json['order_id'];
    _price = json['price'].toDouble();
    _productDetails = json['product_details'] != null
        ? Product.fromJson(json['product_details'])
        : null;
    // if (json['variation'] != null) {
    //   _variation = [];
    //   json['variation'].forEach((v) {
    //     _variation.add(new Variation.fromJson(v));
    //   });
    // }
    _discountOnProduct = json['discount_on_product'].toDouble();
    _discountType = json['discount_type'];
    _quantity = json['quantity'];
    _taxAmount = json['tax_amount'].toDouble();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _reviewCount = json['review_count'];
    if(json['variation']!=null){
      _variation = json['variation'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['product_id'] = _productId;
    data['order_id'] = _orderId;
    data['price'] = _price;
    if (_productDetails != null) {
      data['product_details'] = _productDetails!.toJson();
    }
    // if (this._variation != null) {
    //   data['variation'] = this._variation.map((v) => v.toJson()).toList();
    // }
    data['variation'] = variation;
    data['discount_on_product'] = _discountOnProduct;
    data['discount_type'] = _discountType;
    data['quantity'] = _quantity;
    data['tax_amount'] = _taxAmount;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['review_count'] = _reviewCount;
    return data;
  }
}