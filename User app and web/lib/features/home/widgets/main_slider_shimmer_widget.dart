import 'package:hexacom_user/features/home/providers/banner_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MainSliderShimmerWidget extends StatelessWidget {
  const MainSliderShimmerWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 350 : 300,
      width: Dimensions.webScreenWidth,
      child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [
            Expanded(
              flex: 6,
              child: Shimmer(
                duration: const Duration(seconds: 2),
                enabled: Provider.of<BannerProvider>(context).bannerList == null,
                child: Container(decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 1, blurRadius: 5)],
                  color: Theme.of(context).shadowColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                )),
              ),
            ),

            if(ResponsiveHelper.isDesktop(context)) Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: Provider.of<BannerProvider>(context).bannerList == null,
                  child: Container(decoration: BoxDecoration(
                    boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 1, blurRadius: 5)],
                    color: Theme.of(context).shadowColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                  )),
                ),
              ),
            ),

          ])),
    );
  }
}