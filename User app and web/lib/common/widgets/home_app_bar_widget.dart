import 'package:hexacom_user/common/widgets/cart_count_widget.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({
    super.key,
    required this.drawerGlobalKey,
  });

  final GlobalKey<ScaffoldState> drawerGlobalKey;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).cardColor,
      pinned: ResponsiveHelper.isTab(context) ? true : false,
      leading: ResponsiveHelper.isTab(context) ? IconButton(
        onPressed: () => drawerGlobalKey.currentState!.openDrawer(),
        icon: const Icon(Icons.menu,color: Colors.black),
      ): null,
      title: Consumer<SplashProvider>(builder:(context, splash, child) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomAssetImageWidget(Images.logo, width: 40, height: 40),
          const SizedBox(width: 10),

          Expanded(
            child: Text(AppConstants.appName,
              style: rubikBold.copyWith(color: Theme.of(context).primaryColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      )),
      actions: [

        InkWell(
          borderRadius: BorderRadius.circular(50),
          hoverColor: Colors.transparent,
          onTap: () => RouteHelper.getCouponRoute(context, action: RouteAction.push),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              shape: BoxShape.circle,
            ),

            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(Images.coupon, height: 16, width: 16),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeLarge),

        IconButton(
          onPressed: () => RouteHelper.getNotificationRoute(context, action: RouteAction.push),
          icon: Icon(Icons.notifications, color: Theme.of(context).focusColor, size: 30),
        ),

        if(ResponsiveHelper.isTab(context))IconButton(
          onPressed: () => RouteHelper.getDashboardRoute(context, 'cart', action: RouteAction.push),
          icon: Consumer<CartProvider>(builder: (context, cartProvider, _)=> CartCountWidget(
            count: CartHelper.getCartItemCount(cartProvider.cartList), icon: Icons.shopping_cart,
          )),
        ),
      ],
    );
  }
}
