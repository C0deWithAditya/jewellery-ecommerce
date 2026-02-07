import 'package:dotted_border/dotted_border.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartCouponWidget extends StatelessWidget {
  final TextEditingController couponTextController;
  final double totalAmount;
  const CartCouponWidget({
    Key? key, required this.couponTextController, required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return DottedBorder(
      dashPattern: const [5, 5],
      strokeWidth: 2,
      color: Theme.of(context).primaryColor,
      borderType: BorderType.RRect,
      radius: const Radius.circular(50),
      child: Consumer<CouponProvider>(
        builder: (context, coupon, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            child: Row(children: [

              const CustomAssetImageWidget(Images.cartCouponIcon, width: 30, height: 30),

              Expanded(
                child: TextField(
                  controller: couponTextController,
                  style: rubikRegular,
                  decoration: InputDecoration(
                    hintText: getTranslated('apply_coupon', context),
                    hintStyle: rubikRegular.copyWith(color: Theme.of(context).hintColor),
                    isDense: true,
                    filled: true,
                    enabled: coupon.discount == 0,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(Provider.of<LocalizationProvider>(context, listen: false).isLtr ? 10 : 0),
                        right: Radius.circular(Provider.of<LocalizationProvider>(context, listen: false).isLtr ? 0 : 10),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  if(couponTextController.text.isNotEmpty && !coupon.isLoading) {
                    if(coupon.discount! < 1) {
                      coupon.applyCoupon(couponTextController.text, totalAmount).then((discount) {
                        if (discount! > 0) {
                          showCustomSnackBar('${getTranslated('you_got', context)}${splashProvider.configModel!.currencySymbol}$discount ${getTranslated('discount', context)}', context, isError: false);

                        } else {
                          showCustomSnackBar(getTranslated('invalid_code_or', context), context);

                        }
                      });
                    } else {
                      coupon.removeCouponData(true);
                    }
                  } else if(couponTextController.text.isEmpty) {
                    showCustomSnackBar(getTranslated('enter_a_Coupon_code', context), context);
                  }
                },
                child: Container(
                  height: 40, width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: coupon.discount! <= 0 ? !coupon.isLoading ? Text(
                    getTranslated('apply', context),
                    style: rubikMedium.copyWith(color: Colors.white),
                  ) : const SizedBox(width: Dimensions.paddingSizeDefault, height: Dimensions.paddingSizeDefault,child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Icon(Icons.clear, color: Colors.white),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
