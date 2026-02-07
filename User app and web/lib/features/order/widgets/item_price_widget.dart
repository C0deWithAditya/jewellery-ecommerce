import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/features/cart/widgets/cart_item_widget.dart';
import 'package:flutter/material.dart';

class ItemPriceWidget extends StatelessWidget {
  final double itemsPrice;
  final double tax;
  final double subTotal;
  final double discount;
  final double? extraDiscount;
  final OrderProvider order;
  final double? deliveryCharge;
  final double total;
  const ItemPriceWidget({Key? key, required this.itemsPrice, required this.tax, required this.subTotal, required this.discount, required this.order, required this.deliveryCharge, required this.total, this.extraDiscount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: ResponsiveHelper.isDesktop(context) ? null : BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(children: [

        CartItemWidget(
          title: getTranslated('items_price', context),
          subTitle: PriceConverterHelper.convertPrice(itemsPrice),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CartItemWidget(
          title: getTranslated('tax', context),
          subTitle: PriceConverterHelper.convertPrice( tax),
        ),

        const Divider(height: 20),

        CartItemWidget(
          title: getTranslated('subtotal', context),
          subTitle: PriceConverterHelper.convertPrice(subTotal),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CartItemWidget(
          title: getTranslated('discount', context),
          subTitle: '- ${PriceConverterHelper.convertPrice(discount)}',
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        order.trackModel!.orderType == "pos" ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: CartItemWidget(
            title: getTranslated('extra_discount', context),
            subTitle: '- ${PriceConverterHelper.convertPrice(extraDiscount)}',
          ),
        ) : const SizedBox(),

        CartItemWidget(
          title: getTranslated('coupon_discount', context),
          subTitle: '- ${PriceConverterHelper.convertPrice(order.trackModel!.couponDiscountAmount)}',
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CartItemWidget(
          title: getTranslated('delivery_fee', context),
          subTitle: PriceConverterHelper.convertPrice(deliveryCharge),
        ),

        const Divider(height: 40),

        CartItemWidget(
          title: getTranslated('total_amount', context),
          subTitle: PriceConverterHelper.convertPrice(total),
          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
        ),

      ]),
    );
  }
}