import 'package:hexacom_user/utill/routes.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';

class OrderCancelDialogWidget extends StatelessWidget {
  final int? orderID;
  final bool fromCheckout;
  const OrderCancelDialogWidget({super.key, required this.orderID, required this.fromCheckout});
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: SizedBox(
          width: 300,
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              height: 70, width: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor, size: 50,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            fromCheckout ? Text(
              getTranslated('order_placed_successfully', context),
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
            ) : const SizedBox(),
            SizedBox(height: fromCheckout ? Dimensions.paddingSizeSmall : 0),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${getTranslated('order_id', context)}:', style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(orderID.toString(), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ]),
            const SizedBox(height: 30),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.info, color: Colors.red),
              Text(
                getTranslated('payment_failed', context),
                style: rubikMedium.copyWith(color: Colors.red),
              ),
            ]),
            const SizedBox(height: 10),

            Text(
              getTranslated('payment_process_is_interrupted', context),
              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            Row(children: [
              Expanded(child: SizedBox(
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(width: 2, color: Theme.of(context).primaryColor)),
                  ),
                  onPressed: () {
                    RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
                  },
                  child: Text(getTranslated('maybe_later', context), style: rubikBold.copyWith(color: Theme.of(context).primaryColor)),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: CustomButtonWidget(btnTxt: 'Order Details', onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                RouteHelper.getOrderDetailsRoute(context, orderID, null, action: RouteAction.push);
              })),
            ]),

          ]),
        ),
      ),
    );
  }
}
