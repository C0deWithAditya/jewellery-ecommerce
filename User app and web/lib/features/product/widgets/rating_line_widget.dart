import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class RatingLineWidget extends StatelessWidget {
  const RatingLineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {



    return Consumer<RateReviewProvider>(
      builder: (context, rateReviewProvider, child) {
        double five = (rateReviewProvider.fiveStarLength * 100) / 5;
        double four = (rateReviewProvider.fourStar * 100) / 4;
        double three = (rateReviewProvider.threeStar * 100) / 3;
        double two = (rateReviewProvider.twoStar * 100) / 2;
        double one = (rateReviewProvider.oneStar * 100) / 1;

        return Column(children: [
          Row(children: [
            Expanded(
              flex: ResponsiveHelper.isDesktop(context) ? 3 : 4,
              child: Text(getTranslated('excellent', context),style: rubikRegular.copyWith(
                color: Theme.of(context).hintColor.withOpacity(0.6),
                fontSize: Dimensions.fontSizeDefault,
              )),
            ),

            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.ratingHeight,width: 300,
                  decoration: BoxDecoration(color: ColorResources.getGreyColor(context).withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.ratingHeight,width: convertRatingPercentage(five),
                  decoration: BoxDecoration(color: Colors.green,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            Expanded(
              flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,
              child: Text(getTranslated('good', context), style: rubikRegular.copyWith(
                color: Theme.of(context).hintColor.withOpacity(0.6),
                fontSize: Dimensions.fontSizeDefault,
              )),
            ),

            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.ratingHeight,width: 300,
                  decoration: BoxDecoration(color: ColorResources.getGreyColor(context).withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.ratingHeight,width: convertRatingPercentage(four),
                  decoration: BoxDecoration(color: Colors.greenAccent,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            Expanded(
              flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,
              child: Text(getTranslated('average', context),style: rubikRegular.copyWith(
                color: Theme.of(context).hintColor.withOpacity(0.6),
                fontSize: Dimensions.fontSizeDefault,
              )),
            ),

            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.ratingHeight,width: 300,
                  decoration: BoxDecoration(
                    color: ColorResources.getGreyColor(context).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                Container(
                  height: Dimensions.ratingHeight,width: convertRatingPercentage(three),
                  decoration: BoxDecoration(color: Colors.orange,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            Expanded(
              flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,
              child: Text(getTranslated('below_average', context),style: rubikRegular.copyWith(
                color: Theme.of(context).hintColor.withOpacity(0.6),
                fontSize: Dimensions.fontSizeDefault,
              )),
            ),

            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.ratingHeight,width: 300,
                  decoration: BoxDecoration(color: ColorResources.getGreyColor(context).withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.ratingHeight,width: convertRatingPercentage(two),
                  decoration: BoxDecoration(color: Colors.deepOrange,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            Expanded(
              flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,
              child: Text(getTranslated('poor', context),style: rubikRegular.copyWith(
                color: Theme.of(context).hintColor.withOpacity(0.6),
                fontSize: Dimensions.fontSizeDefault,
              )),
            ),

            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.ratingHeight,width: 300,
                  decoration: BoxDecoration(
                    color: ColorResources.getGreyColor(context).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  height: Dimensions.ratingHeight,width: convertRatingPercentage(one),
                  decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            )),
          ]),
        ],);
      }
    );
  }

  double convertRatingPercentage(double percent)=> 300 * (percent / 100);
}
