import 'package:hexacom_user/features/product/domain/models/review_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/rating_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../helper/date_converter_helper.dart';

class ReviewWidget extends StatelessWidget {
  final ReviewModel reviewModel;
  const ReviewWidget({Key? key, required this.reviewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: FadeInImage.assetNetwork(
              image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${
                  reviewModel.customer != null ? reviewModel.customer!.image : getTranslated('user_not_available', context)
                }',
              placeholder: Images.placeholder(context),
              width: 50, height: 50, fit: BoxFit.cover,
              imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), width: 50, height: 50,fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeLarge),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reviewModel.customer != null ?
                '${reviewModel.customer!.fName} ${reviewModel.customer!.lName}' : getTranslated('user_not_available', context),
                style: rubikBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RatingBarWidget(rating: reviewModel.rating != null ? double.parse(reviewModel.rating.toString()) : 0.0, size: 16,color: Theme.of(context).primaryColor),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(reviewModel.rating!.toStringAsFixed(1), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge,color: ColorResources.getGreyColor(context))),

                ],
              ),

            ],
          ),
          const Spacer(),

          Text(DateConverterHelper.convertToAgo(reviewModel.createdAt!), style: rubikRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).hintColor.withOpacity(0.6),
          )),
        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Text(reviewModel.comment!, style: rubikRegular.copyWith(
          fontSize: ResponsiveHelper.isDesktop(context)
              ? Dimensions.fontSizeLarge
              : Dimensions.fontSizeDefault ,
          color: Theme.of(context).hintColor.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        )),
      ]),
    );
  }
}

class ReviewShimmer extends StatelessWidget {
  const ReviewShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorResources.getSearchBg(context),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(height: 30, width: 30, decoration: BoxDecoration(color: Theme.of(context).shadowColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Container(height: 15, width: 100, color: Theme.of(context).shadowColor),
            const Expanded(child: SizedBox()),
            Icon(Icons.star, color: Theme.of(context).primaryColor, size: 18),
            const SizedBox(width: 5),
            Container(height: 15, width: 20, color: Theme.of(context).shadowColor),
          ]),
          const SizedBox(height: 5),
          Container(height: 15, width: MediaQuery.of(context).size.width, color: Theme.of(context).shadowColor),
          const SizedBox(height: 3),
          Container(height: 15, width: MediaQuery.of(context).size.width, color: Theme.of(context).shadowColor),
        ]),
      ),
    );
  }
}

