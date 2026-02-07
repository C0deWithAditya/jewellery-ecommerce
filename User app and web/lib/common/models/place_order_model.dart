import 'package:hexacom_user/common/models/product_model.dart';

class PlaceOrderModel {
  List<Cart>? _cart;
  double? _couponDiscountAmount;
  String? _couponDiscountTitle;
  double? _orderAmount;
  String? _orderType;
  int? _deliveryAddressId;
  String? _paymentMethod;
  String? _orderNote;
  String? _couponCode;
  int? _branchId;
  double? _distance;
  String? _transactionReference;
  int? _selectedDeliveryArea;


  PlaceOrderModel copyWith({String? paymentMethod, String? transactionReference}) {
    _paymentMethod = paymentMethod;
    _transactionReference = transactionReference;
    return this;
  }

  PlaceOrderModel(
      {required List<Cart> cart,
        required double? couponDiscountAmount,
        required String couponDiscountTitle,
        required String? couponCode,
        required double orderAmount,
        required int? deliveryAddressId,
        required String? orderType,
        required String? paymentMethod,
        required int? branchId,
        required String orderNote,
        required double distance,
        String? transactionReference,
        int? selectedDeliveryArea
      }) {
    _cart = cart;
    _couponDiscountAmount = couponDiscountAmount;
    _couponDiscountTitle = couponDiscountTitle;
    _orderAmount = orderAmount;
    _orderType = orderType;
    _deliveryAddressId = deliveryAddressId;
    _paymentMethod = paymentMethod;
    _orderNote = orderNote;
    _couponCode = couponCode;
    _branchId = branchId;
    _distance = distance;
    _transactionReference = transactionReference;
    _selectedDeliveryArea = selectedDeliveryArea;
  }

  List<Cart>? get cart => _cart;
  double? get couponDiscountAmount => _couponDiscountAmount;
  String? get couponDiscountTitle => _couponDiscountTitle;
  double? get orderAmount => _orderAmount;
  String? get orderType => _orderType;
  int? get deliveryAddressId => _deliveryAddressId;
  String? get paymentMethod => _paymentMethod;
  String? get orderNote => _orderNote;
  String? get couponCode => _couponCode;
  int? get branchId => _branchId;
  double? get distance => _distance;
  String? get transactionReference => _transactionReference;
  int? get selectedDeliveryArea => _selectedDeliveryArea;


  PlaceOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['cart'] != null) {
      _cart = [];
      json['cart'].forEach((v) {
        _cart!.add(Cart.fromJson(v));
      });
    }
    _couponDiscountAmount = json['coupon_discount_amount'];
    _couponDiscountTitle = json['coupon_discount_title'];
    _orderAmount = json['order_amount'];
    _orderType = json['order_type'];
    _deliveryAddressId = json['delivery_address_id'];
    _paymentMethod = json['payment_method'];
    _orderNote = json['order_note'];
    _couponCode = json['coupon_code'];
    _branchId = json['branch_id'];
    _distance = json['distance'];
    _selectedDeliveryArea = json['selected_delivery_area'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_cart != null) {
      data['cart'] = _cart!.map((v) => v.toJson()).toList();
    }
    data['coupon_discount_amount'] = _couponDiscountAmount;
    data['coupon_discount_title'] = _couponDiscountTitle;
    data['order_amount'] = _orderAmount;
    data['order_type'] = _orderType;
    data['delivery_address_id'] = _deliveryAddressId;
    data['payment_method'] = _paymentMethod;
    data['order_note'] = _orderNote;
    data['coupon_code'] = _couponCode;
    data['branch_id'] = _branchId;
    data['distance'] = _distance;
    data['selected_delivery_area'] = selectedDeliveryArea;
    if(_transactionReference != null) {
      data['transaction_reference'] = _transactionReference;
    }
    return data;
  }
}

class Cart {
  String? _productId;
  String? _price;
  String? _variant;
  List<Variation>? _variation;
  double? _discountAmount;
  int? _quantity;
  double? _taxAmount;

  Cart(
      String productId,
        String price,
        String variant,
        List<Variation>? variation,
        double? discountAmount,
        int? quantity,
        double? taxAmount) {
    _productId = productId;
    _price = price;
    _variant = variant;
    _variation = variation;
    _discountAmount = discountAmount;
    _quantity = quantity;
    _taxAmount = taxAmount;
  }

  String? get productId => _productId;
  String? get price => _price;
  String? get variant => _variant;
  List<Variation>? get variation => _variation;
  double? get discountAmount => _discountAmount;
  int? get quantity => _quantity;
  double? get taxAmount => _taxAmount;

  Cart.fromJson(Map<String, dynamic> json) {
    _productId = json['product_id'];
    _price = json['price'];
    _variant = json['variant'];
    if (json['variation'] != null) {
      _variation = [];
      json['variation'].forEach((v) {
        _variation!.add(Variation.fromJson(v));
      });
    }
    _discountAmount = json['discount_amount'];
    _quantity = json['quantity'];
    _taxAmount = json['tax_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = _productId;
    data['price'] = _price;
    data['variant'] = _variant;
    if (_variation != null) {
      data['variation'] = _variation!.map((v) => v.toJson()).toList();
    }
    data['discount_amount'] = _discountAmount;
    data['quantity'] = _quantity;
    data['tax_amount'] = _taxAmount;
    return data;
  }
}
