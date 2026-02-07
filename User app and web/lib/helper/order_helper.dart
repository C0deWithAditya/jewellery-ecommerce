// Order Status
// ignore_for_file: constant_identifier_names

import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/common/models/reorder_details_model.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/order_constants.dart';
import 'package:provider/provider.dart';


class OrderHelper {

  static Branches? getBranch({required int id,required List<Branches> branchList}){
    Branches? branches;
    for(Branches branch in branchList) {
      if(id == branch.id) {
        branches = branch;
        break;
      }
    }
    return branches;
  }

  static int getOrderItemQuantity(List<OrderDetailsModel>? orderDetailsList){
    int quantity = 0;
    if(orderDetailsList != null) {
      for(int i = 0; i < orderDetailsList.length; i++) {
        quantity = quantity + (orderDetailsList[i].quantity ?? 0);
      }
    }
    return quantity;
  }

  static String? getVariationType(List<Variation>? productVariationList, String? orderedVariation ) {
    String? type;
    if(productVariationList != null && orderedVariation != null) {
      for(int i = 0; i < productVariationList.length; i++) {
        if(productVariationList[i].type != null && orderedVariation.contains(productVariationList[i].type!)) {
          type = productVariationList[i].type;
        }
      }
    }

    return type;
  }


  static List<CartModel> getReorderCartData({required ReOrderDetailsModel reOrderDetailsModel}) {


    List<CartModel> cartList = [];

    for(OrderDetailsModel orderDetail in reOrderDetailsModel.orderDetails ?? []) {

      Product? product = _getReorderProduct(reOrderDetailsModel, orderDetail);

      List<Variation>? variationList = [];
      double price = product?.price ?? 0;

      if(_getVariationForCart(orderDetail, product) != null) {
        variationList.add(_getVariationForCart(orderDetail, product)!);
        price = _getVariationForCart(orderDetail, product)!.price ?? 0;
      }


      if(product != null) {

        cartList.add(CartModel(
          product.id, price,
          PriceConverterHelper.convertWithDiscount(price, product.discount, product.discountType),
          variationList, (price - (PriceConverterHelper.convertWithDiscount(price, product.discount, product.discountType) ?? 0)), 1,
          price -  (PriceConverterHelper.convertWithDiscount(price, product.tax, product.taxType) ?? 0), product.totalStock,
          product,
        ));
      }
    }

    return cartList;
  }

  static Product? _getReorderProduct(ReOrderDetailsModel reOrderDetailsModel, OrderDetailsModel orderDetail){
    Product? product;
    for(int i = 0; i < (reOrderDetailsModel.products?.length ?? 0); i++) {
      if(orderDetail.productId == reOrderDetailsModel.products?[i].id) {
        product = reOrderDetailsModel.products?[i];
      }
    }

    return product;
  }

  static Product? getOrderedProductProduct(ReOrderDetailsModel? reOrderDetailsModel, int? productId ){
    Product? product;
    for(int i = 0; i < (reOrderDetailsModel?.orderDetails?.length ?? 0); i++) {
      if(productId == reOrderDetailsModel?.orderDetails?[i].productId) {
        product = reOrderDetailsModel?.orderDetails?[i].productDetails;
      }
    }

    return product;
  }



  static Variation? _getVariationForCart(OrderDetailsModel orderDetail, Product? product) {
    Variation? variation;
    String? orderedVariation = orderDetail.variation;
    String? type;
    double? price;
    int? stock;

    if(orderedVariation != null && orderedVariation.isNotEmpty){

      type = OrderHelper.getVariationType(orderDetail.productDetails?.variations, orderedVariation);

      for(Variation value in (product?.variations ?? [])) {
        if(type == value.type) {
          stock =  value.stock;
          price =  value.price;
        }
      }


       variation = Variation(type: type, price: price, stock: stock);
    }

    return variation;
  }


  static bool addToCartReorderProduct({required List<CartModel> cartList}){
    final CartProvider cartProvider = Provider.of<CartProvider>(Get.context!, listen: false);
    List<CartModel> availableCartList = [];
    Navigator.pop(Get.context!);

    for(int i = 0; i < cartList.length; i++) {

      bool isVariationStockAvailable = true;

      if(((cartList[i].variation?.length ?? 0) > 0) && ((cartList[i].variation?.first.stock ?? 0) < 1) ){
        isVariationStockAvailable = false;
      }

      if(cartProvider.getCartProductIndex(cartList[i]) == null && ((cartList[i].stock ?? 0) > 0) && isVariationStockAvailable) {
        availableCartList.add(cartList[i]);
      }
    }

    if(availableCartList.isNotEmpty) {
      for (var cartModel in availableCartList) {
        cartProvider.addToCart(cartModel, null);
      }
    }

    return availableCartList.isNotEmpty;
  }

  static bool isShowDeliveryAddress(OrderModel? trackOrder) {
    return trackOrder != null && trackOrder.orderType == OrderConstants.deliveryType && trackOrder.deliveryAddress != null;
  }
}