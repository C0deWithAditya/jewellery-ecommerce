import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class TabBarWidget extends StatelessWidget {
  final int? productId;
  const TabBarWidget({
    Key? key,
    required this.child, required this.productId,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);
    final RateReviewProvider rateReviewProvider = Provider.of<RateReviewProvider>(context, listen: false);
    final bool isDesktopSize = ResponsiveHelper.isDesktop(context);

    return SizedBox(
      width: Dimensions.webScreenWidth,
      child: Column(
        children: [
          Row(children: [
            InkWell(
              hoverColor: Colors.transparent,
              onTap: () => productProvider.setTabIndex(0),
              child: Column(children: [

                Center(child: Text(getTranslated('description', context), style: productProvider.tabIndex == 0 ? isDesktopSize ?  rubikBold.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge,
                  color: Theme.of(context).primaryColor.withOpacity(1),
                ) : rubikMedium.copyWith(
                  color: Theme.of(context).primaryColor,
                ) : isDesktopSize ? rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge,
                  color: Theme.of(context).disabledColor,
                ) : rubikRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                ))),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(height: 4, width: isDesktopSize ? 170 : 100, color: Theme.of(context).primaryColor.withOpacity(productProvider.tabIndex == 0 ? 1 : 0.07)),

              ]),
            ),

            InkWell(
              hoverColor: Colors.transparent,
              onTap: () async {
                productProvider.setTabIndex(1);
                await rateReviewProvider.getProductReviews(productId);
              },
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Padding(
                  padding: EdgeInsets.only(left: isDesktopSize ? 30 : 50),
                  child: Text(getTranslated('review', context), style: productProvider.tabIndex == 1 ? isDesktopSize ?  rubikBold.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge,
                    color: Theme.of(context).primaryColor.withOpacity(1),
                  ) : rubikMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                  ) : isDesktopSize ? rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge,
                    color: Theme.of(context).disabledColor,
                  ) : rubikRegular.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),  textAlign: TextAlign.center),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Stack(
                  children: [
                    Container(
                      height: 4,
                      color: Theme.of(context).primaryColor.withOpacity(0.07),
                    ),

                    Container(height: 4, width: 140, color: Theme.of(context).primaryColor.withOpacity(productProvider.tabIndex.toDouble())),
                  ],
                ),

              ]),
            ),
          ]),

          !ResponsiveHelper.isTab(context) ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox.shrink(),

          child,

          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}
