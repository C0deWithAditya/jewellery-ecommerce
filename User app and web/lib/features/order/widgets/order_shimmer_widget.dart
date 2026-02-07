import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderShimmerWidget extends StatelessWidget {
  const OrderShimmerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: ListView.builder(
          itemCount: 10,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 1, blurRadius: 5)],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Shimmer(
                duration: const Duration(seconds: 2),
                enabled: Provider.of<OrderProvider>(context).runningOrderList == null,
                child: ResponsiveHelper.isDesktop(context) ? Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children: [

                  Container(height: 15, width: 100, color: Theme.of(context).shadowColor),

                  Container(height: 15, width: 150, color: Theme.of(context).shadowColor),

                  Container(height: 15, width: 80, color: Theme.of(context).shadowColor),

                  Container(
                    margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                    height: 20, width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Container(
                    height: 40, width: 150,
                    decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(30)),
                  ),

                ],) : Column(children: [

                  Row(children: [
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(height: 15, width: 150, color: Theme.of(context).shadowColor),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(height: 15, width: 100, color: Theme.of(context).shadowColor),
                    ]),
                  ]),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(
                      margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                      height: 20, width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    Container(
                      height: 40, width: 150,
                      decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(30)),
                    ),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
