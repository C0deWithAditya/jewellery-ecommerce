import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryShimmerWidget extends StatelessWidget {
  const CategoryShimmerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 200 : 80,
      child: ListView.builder(
        itemCount: ResponsiveHelper.isDesktop(context) ? 13 : 10,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: ResponsiveHelper.isDesktop(context) ? 10 : Dimensions.paddingSizeSmall),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: Provider.of<CategoryProvider>(context).categoryList == null,
              child: Column(children: [
                Container(
                  height: ResponsiveHelper.isDesktop(context) ? 100 : 65,
                  width: ResponsiveHelper.isDesktop(context) ? 100 : 65,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                    height: 10, width: 50, color: Theme.of(context).shadowColor),
              ]),
            ),
          );
        },
      ),
    ) :  SizedBox(
      height: 80,
      child: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: Provider.of<CategoryProvider>(context).categoryList == null,
              child: Column(children: [
                Container(
                  height: 65, width: 65,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Container(height: 10, width: 50, color: Theme.of(context).shadowColor),
              ]),
            ),
          );
        },
      ),
    );
  }
}
