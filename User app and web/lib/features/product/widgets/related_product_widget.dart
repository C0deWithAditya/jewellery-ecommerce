import 'package:hexacom_user/common/models/product_details_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_single_child_list_widget.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:flutter/material.dart';

class RelatedProductWidget extends StatelessWidget {
  final ProductDetailsModel? productDetailsModel;
  const RelatedProductWidget({super.key, this.productDetailsModel});

  @override
  Widget build(BuildContext context) {

    return productDetailsModel != null  && productDetailsModel?.relatedProducts != null && productDetailsModel!.relatedProducts!.isNotEmpty ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(getTranslated('similar_items_you_might_also_like', context), style: rubikMedium.copyWith(
        fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault
      )),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        width: Dimensions.webScreenWidth,
        color: Theme.of(context).canvasColor,
        child: CustomSingleChildListWidget(
          crossAxisAlignment: CrossAxisAlignment.start,
          scrollDirection: Axis.horizontal,
          itemCount: productDetailsModel?.relatedProducts?.length ?? 0,
          itemBuilder: (index) => Container(
            width: 190,
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            child: AspectRatio(
              aspectRatio: 2.5/4,
              child: ProductCardWidget(product: productDetailsModel!.relatedProducts![index]),
            ),
          ),
        ),
      )


    ]) : const SizedBox();
  }
}
