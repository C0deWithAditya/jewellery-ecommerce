import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';

class WishLIstShimmerWidget extends StatelessWidget {
  const WishLIstShimmerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 10,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
            mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
            childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 4,
            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1,
          ),
          itemBuilder: (context, index) {
            return ProductShimmerWidget(isEnabled: true,isWeb:  ResponsiveHelper.isDesktop(context) ? true : false);
          },
        ),
      ),
    );
  }
}
