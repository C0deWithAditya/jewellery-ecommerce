import 'package:flutter/material.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/cart/widgets/button_view_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_details_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_product_list_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  final bool fromDetails;
  const CartScreen({super.key, this.fromDetails = false});

  @override
  Widget build(BuildContext context) {
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    Provider.of<CheckoutProvider>(context, listen: false).setOrderType('delivery', notify: false);
    final TextEditingController couponController = TextEditingController();
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('my_cart', context), isBackButtonExist: fromDetails),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          double? deliveryCharge = 0;
          double itemPrice = 0;
          double discount = 0;
          double tax = 0;
          for (var cartModel in cart.cartList) {
            itemPrice = itemPrice + (cartModel!.price! * cartModel.quantity!);
            discount = discount + (cartModel.discountAmount! * cartModel.quantity!);
            tax = tax + (cartModel.taxAmount! * cartModel.quantity!);
          }
          double subTotal = itemPrice + tax;
          double total = subTotal - discount - Provider.of<CouponProvider>(context).discount! + deliveryCharge!;

          return cart.cartList.isNotEmpty ? Column(children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                        width: Dimensions.webScreenWidth,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              CustomWebTitleWidget(title: getTranslated('cart', context)),

                              if(!ResponsiveHelper.isDesktop(context)) const CartProductListWidget(),
                              // Product

                              if(!ResponsiveHelper.isDesktop(context)) CartDetailsWidget(
                                itemPrice: itemPrice,
                                tax: tax,
                                discount: discount,
                                deliveryCharge: deliveryCharge,
                                total: total, couponController: couponController,
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(ResponsiveHelper.isDesktop(context)) const Expanded(flex: 6, child: CartProductListWidget()),
                                  const SizedBox(width: Dimensions.paddingSizeLarge),

                                  if(ResponsiveHelper.isDesktop(context)) Expanded(flex: 4, child: CartDetailsWidget(
                                    itemPrice: itemPrice,
                                    tax: tax,
                                    discount: discount,
                                    deliveryCharge: deliveryCharge,
                                    total: total, couponController: couponController,
                                  )),
                                ],
                              ),
                              // Order type


                            ]),
                      ),
                    ),

                    const FooterWebWidget(footerType: FooterType.nonSliver),

                  ],
                ),
              ),
            ),

            if(!ResponsiveHelper.isDesktop(context)) ButtonViewWidget(
              itemPrice: itemPrice,total: total,
              deliveryCharge: deliveryCharge, discount: discount,
            ),

          ]) : NoDataScreen(
            image: Images.wishListNoData ,
            title: getTranslated('empty_cart', context),
            subTitle: getTranslated('look_like_have_not_added', context),
            showFooter: true,
          );
        },
      ),
    );
  }




}




