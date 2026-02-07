import 'package:hexacom_user/common/widgets/rating_bar_widget.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/product/widgets/rating_line_widget.dart';
import 'package:hexacom_user/features/product/widgets/review_widget.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ProductReviewListWidget extends StatelessWidget {
  const ProductReviewListWidget({
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);

    return Consumer<RateReviewProvider>(builder: (context, rateReviewProvider, _) {
      return rateReviewProvider.productReviewList == null ? const ReviewShimmer() : rateReviewProvider.productReviewList!.isNotEmpty ? Column(children: [
        SizedBox(width: 700, child: ResponsiveHelper.isDesktop(context) ? Row(children: [
          Expanded(
            flex:4,
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

              Text('${ productProvider.product!.rating!.isNotEmpty ? double.parse(productProvider.product!.rating!.first.average!).toStringAsFixed(1) : 0.0}',style: TextStyle(fontSize: 70,fontWeight: FontWeight.w700,color: Theme.of(context).primaryColor)),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              RatingBarWidget(rating: productProvider.product!.rating!.isNotEmpty ? double.parse(productProvider.product!.rating![0].average!) : 0.0, size: 30,color: Theme.of(context).primaryColor),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Text('${rateReviewProvider.productReviewList?.length} ${getTranslated((rateReviewProvider.productReviewList?.length ?? 0) > 1 ? 'reviews' : 'review', context)}',style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).primaryColor)),
              ]),

            ]),
          ),

          const Expanded(flex:6,child: RatingLineWidget()),
        ]) : Column(children: [
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          SizedBox(height: 150,child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

            Text('${productProvider.product!.rating!.isNotEmpty ? double.parse(productProvider.product!.rating!.first.average!).toStringAsFixed(1) : 0.0}',style: TextStyle(fontSize: 40,fontWeight: FontWeight.w700,color: Theme.of(context).primaryColor)),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            RatingBarWidget(rating: productProvider.product!.rating!.isNotEmpty ? double.parse(productProvider.product!.rating![0].average!) : 0.0, size: 30,color: Theme.of(context).primaryColor),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            const SizedBox(width: Dimensions.paddingSizeDefault),

            Text('${rateReviewProvider.productReviewList?.length} ${getTranslated((rateReviewProvider.productReviewList?.length ?? 0) > 1 ? 'reviews' : 'review', context)}',style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).primaryColor)),

          ])),

          SizedBox(
            width: size.width,
            child: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: RatingLineWidget(),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ]),
        ),

        ListView.builder(
          itemCount: rateReviewProvider.productReviewList?.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          itemBuilder: (context, index) {
            return rateReviewProvider.productReviewList != null ? ReviewWidget(
              reviewModel: rateReviewProvider.productReviewList![index],
            ) : const ReviewShimmer();
          },
        ),

      ]) : Center(child: Text(
        getTranslated('no_review_found', context),
        style: TextStyle(fontSize: ResponsiveHelper.isDesktop(context) ? 20 : 16),
      ));
    });
  }
}
