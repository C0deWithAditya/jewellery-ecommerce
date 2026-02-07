import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/responsive_helper.dart';


class ProductTitleWidget extends StatelessWidget {
  final Product? productModel;
  const ProductTitleWidget({Key? key, required this.productModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Consumer<ProductProvider>(
        builder: (context, product, child){
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              productModel!.name ?? '',
              style: rubikMedium.copyWith(
                fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeOverLarge : Dimensions.fontSizeExtraLarge,
              ),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),

            if(productModel!.rating != null && productModel!.rating!.isNotEmpty) Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: ColorResources.getRatingColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [

                  Icon(Icons.star, color: ColorResources.getRatingColor(context), size: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text(
                    double.parse(productModel!.rating![0].average!).toStringAsFixed(1),
                    style: rubikRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                  ),

                ]),
              ),

          ]);
    });
  }
}
