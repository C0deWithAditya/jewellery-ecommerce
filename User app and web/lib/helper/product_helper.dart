import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/features/home/domain/models/banner_model.dart';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ProductHelper{
  static String getProductFilterTypeValue(ProductFilterType filterType) {
    String type;
    switch (filterType) {
      case ProductFilterType.highToLow:
        type = 'price_high_to_low';
        break;
      case ProductFilterType.lowToHigh:
        type = 'price_low_to_high';
        break;
    }

    return type;
  }

  static double? getProductRatingValue(Product? product) {
    double? rating;
    if(product != null && product.rating != null && product.rating!.isNotEmpty && product.rating!.first.average != null){
      rating = double.tryParse('${product.rating!.first.average}');
    }
    return rating;
  }

  static void onTapBannerForRoute(BannerModel bannerModel, BuildContext context){
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    if(bannerModel.productId != null) {
      RouteHelper.getProductDetailsRoute(context, bannerModel.productId, action: RouteAction.push);

    }else if(bannerModel.categoryId != null) {
      CategoryModel? category;
      for(CategoryModel categoryModel in categoryProvider.categoryList!) {
        if(categoryModel.id == bannerModel.categoryId) {
          category = categoryModel;
          break;
        }
      }
      if(category != null) {
        RouteHelper.getCategoryRoute(context, category, action: RouteAction.push);
      }
    }
  }
}