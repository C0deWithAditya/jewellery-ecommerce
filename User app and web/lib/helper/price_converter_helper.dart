import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:provider/provider.dart';

class PriceConverterHelper {
  static String convertPrice(double? price, {double? discount, String? discountType, int asFixed = 2}) {
    final ConfigModel configModel =  Provider.of<SplashProvider>(Get.context!, listen: false).configModel!;
    if(discount != null && discountType != null){
      if(discountType == 'amount') {
        price = price! - discount;
      }else if(discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    return configModel.currencySymbolPosition == 'left' ? '${configModel.currencySymbol} '
        '${price!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}':

    '${price!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}''${configModel.currencySymbol} ';
  }

  static double? convertWithDiscount(double? price, double? discount, String? discountType) {
    if(discountType == 'amount') {
      price = price! - discount!;
    }else if(discountType == 'percent') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static double calculation(double amount, double discount, String type, int quantity) {
    double calculatedAmount = 0;
    if(type == 'amount') {
      calculatedAmount = discount * quantity;
    }else if(type == 'percent') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(BuildContext context, double price, double discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : Provider.of<SplashProvider>(context, listen: false).configModel!.currencySymbol} OFF';
  }

  static PriceRange getPriceRange(Product product) {
    double? startingPrice;
    double? endingPrice;
    if(product.variations!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in product.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if(priceList[0]! < priceList[priceList.length-1]!) {
        endingPrice = priceList[priceList.length-1];
      }
    }else {
      startingPrice = product.price;

    }
    return PriceRange(startPrice: startingPrice, endPrice: endingPrice);
  }

}