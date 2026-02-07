import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/rating_bar_widget.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProductShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isWeb;
  const ProductShimmerWidget({super.key, required this.isEnabled, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 85,
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraSmall,
          horizontal: Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 10, spreadRadius: 1)
        ],
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: isEnabled,
        child: isWeb
            ? Column(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Container(
                        height: 15,
                        width: double.maxFinite,
                        color: Theme.of(context).shadowColor),
                    const SizedBox(height: 5),
                    const RatingBarWidget(rating: 0.0, size: 12),
                    const SizedBox(height: 10),
                    Container(
                        height: 10, width: 50, color: Theme.of(context).shadowColor),
                  ]),
                  const SizedBox(width: 10),
                  ],
              )
            : Row(children: [
                Container(
                  height: 70,
                  width: 85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).shadowColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Container(
                          height: 15,
                          width: double.maxFinite,
                          color: Theme.of(context).shadowColor),
                      const SizedBox(height: 5),
                      const RatingBarWidget(rating: 0.0, size: 12),
                      const SizedBox(height: 10),
                      Container(height: 10, width: 50, color: Theme.of(context).shadowColor),
                    ])),
                const SizedBox(width: 10),

              ]),
      ),
    );
  }
}
