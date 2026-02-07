import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishButtonWidget extends StatelessWidget {
  final Product? product;
  final EdgeInsetsGeometry edgeInset;
  final bool countVisible;
  const WishButtonWidget({super.key, required this.product, this.edgeInset = EdgeInsets.zero, this.countVisible = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishListProvider>(builder: (context, wishList, child) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        child: Row(children: [

          InkWell(
            onTap: () {
              if(Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
                List<int?> productIdList =[];
                productIdList.add(product!.id);
                if(wishList.wishIdList.contains(product!.id)) {

                  ResponsiveHelper.showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                    title: getTranslated('remove_from_wish_list', context),
                    subTitle: getTranslated('remove_this_item_from_your_favorite_list', context),
                    icon: Icons.contact_support_outlined,
                    leftButtonText: getTranslated('cancel', context),
                    rightButtonText: getTranslated('remove', context),
                    buttonColor: Theme.of(context).colorScheme.error.withOpacity(0.9),
                    onPressRight: (){
                      Navigator.pop(context);
                      wishList.removeFromWishList(product!, context);

                    },

                  ));



                }else{
                  wishList.addToWishList(product!);
                }

              }else{
                showCustomSnackBar(getTranslated('now_you_are_in_guest_mode', context), context);
              }

            },
            child: Padding(
              padding: edgeInset,
              child: Icon(
                wishList.wishIdList.contains(product!.id) ? Icons.favorite : Icons.favorite_border,
                color: wishList.wishIdList.contains(product!.id) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
              ),
            ),
          ),

          if(countVisible)
          wishList.wishProduct!.wishlistCount! > 0 ? Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeExtraSmall),
            child: Text('${wishList.wishProduct?.wishlistCount}',style: rubikMedium.copyWith(
            color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraLarge),
            ),
          ) : const SizedBox(),
        ]),
      );
    });
  }
}
