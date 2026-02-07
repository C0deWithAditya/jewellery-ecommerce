import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_shadow_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/features/cart/widgets/cart_item_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/payment_info_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/place_order_button_view.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class DetailsViewWidget extends StatelessWidget {
  final bool kmWiseCharge;
  final bool selfPickup;
  final double deliveryCharge;
  final double amount;
  final TextEditingController orderNoteController;
  final List<CartModel?> cartList;
  final String? orderType;
  final ScrollController? scrollController;
  final GlobalKey? dropdownKey;



  const DetailsViewWidget({
    super.key, required this.kmWiseCharge,
    required this.selfPickup,
    required this.deliveryCharge,
    required this.orderNoteController,
    required this.amount, required this.cartList, required this.orderType,
    this.scrollController, this.dropdownKey
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const PaymentInfoWidget(),

        CustomShadowWidget(
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getTranslated('add_delivery_note', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CustomTextFieldWidget(
              fillColor: Theme.of(context).canvasColor,
              isShowBorder: true,
              controller: orderNoteController,
              hintText: getTranslated('type', context),
              maxLines: 5,
              inputType: TextInputType.multiline,
              inputAction: TextInputAction.newline,
              capitalization: TextCapitalization.sentences,
            ),
          ]),
        ),

        CustomShadowWidget(
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Column(children: [
              CartItemWidget(
                title: getTranslated('subtotal', context),
                subTitle: PriceConverterHelper.convertPrice(amount),
                style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: 10),


              if(!selfPickup)...[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    getTranslated('delivery_fee', context),
                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),

                  Selector<OrderProvider, double?>(
                    selector: (context, orderProvider) => orderProvider.deliveryCharge,
                    builder: (context, deliveryCharge, child){
                      return CustomDirectionalityWidget(
                        child: Text(
                          '(+) ${PriceConverterHelper.convertPrice(deliveryCharge ?? 0.0)}',
                          style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                      );
                    },
                  )
                ]),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Divider(),
              ),

              Selector<OrderProvider, double?>(
                selector: (context, orderProvider) => orderProvider.deliveryCharge,
                builder: (context, deliveryCharge, child) {
                  return CartItemWidget(
                    title: getTranslated('total_amount', context),
                    subTitle: PriceConverterHelper.convertPrice(amount + (deliveryCharge ?? 0.0)),
                    style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  );
                }
              ),

              if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: Dimensions.paddingSizeDefault),


              if(ResponsiveHelper.isDesktop(context))  PlaceOrderButtonView(
                amount: amount, deliveryCharge: deliveryCharge,
                orderType: orderType,
                kmWiseCharge: kmWiseCharge,
                cartList: cartList,
                orderNote: orderNoteController.text,
                scrollController: scrollController,
                dropdownKey: dropdownKey,
              )

            ]),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),


      ],
    );
  }
}
