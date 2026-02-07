import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_shadow_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/selected_payment_widget.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'payment_method_bottom_sheet_widget.dart';
class PaymentInfoWidget extends StatelessWidget {
  const PaymentInfoWidget({Key? key}) : super(key: key);


  void openDialog(BuildContext context){
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);

    if (!CheckOutHelper.isSelfPickup(orderType: checkoutProvider.orderType) && checkoutProvider.orderAddressIndex == -1) {
      showCustomSnackBar(getTranslated('select_delivery_address', context), context, isError: true);
    }else {
      if(!ResponsiveHelper.isMobile(context)){
        showDialog(
          context: context,
          builder: (con) => const PaymentMethodBottomSheetWidget(),
        );
      }else{
        showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const PaymentMethodBottomSheetWidget(),
        );
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(builder: (context, checkoutProvider, _) {
      bool showPayment = checkoutProvider.selectedPaymentMethod != null;
      return CustomShadowWidget(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getTranslated('payment_method', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

           if(showPayment) Flexible(
              child: InkWell(
                onTap: ()=> openDialog(context),
                child: const CustomAssetImageWidget(Images.edit),
              ),
            )
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          const Divider(height: 1),

           if(!showPayment ) Padding(
             padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
             child: InkWell(
               onTap: ()=> openDialog(context),
               child: Row(children: [
                 Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                 const SizedBox(width: Dimensions.paddingSizeDefault),

                 Flexible(
                   child: Text(
                     getTranslated('add_payment_method', context),
                     style: rubikMedium,
                   ),
                 ),

               ]),
             ),
           ),

           if(ResponsiveHelper.isDesktop(context) && showPayment) const SizedBox(height: Dimensions.paddingSizeDefault),

           if(showPayment) SelectedPaymentWidget(total: (checkoutProvider.getCheckOutData?.amount ?? 0)),

          ]),
      );
    });
  }
}


