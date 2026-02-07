import 'package:hexacom_user/features/order/enums/order_status_enum.dart';
import 'package:hexacom_user/helper/date_converter_helper.dart';
import 'package:hexacom_user/helper/order_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderInfoWidget extends StatelessWidget {
  const OrderInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    int itemsQuantity = OrderHelper.getOrderItemQuantity(Provider.of<OrderProvider>(context, listen: false).orderDetails);
    final SplashProvider splashProvider  = context.read<SplashProvider>();
    final OrderProvider orderProvider  = context.read<OrderProvider>();

    print("------------(ORDER INFO WIDGET)------------${orderProvider.trackModel?.toJson().toString()}");

    return Consumer<OrderProvider>(
      builder: (context, order, _) {
        return Column(children: [

          ResponsiveHelper.isDesktop(context) ? Row(children: [

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row( children: [

                  Text('${getTranslated('order_id', context)}:', style: rubikRegular),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text(order.trackModel!.id.toString(), style: rubikMedium),

                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: OrderStatus.pending.name == order.trackModel!.orderStatus ? ColorResources.colorBlue.withOpacity(0.08)
                          : OrderStatus.out_for_delivery.name == order.trackModel!.orderStatus ? ColorResources.getRatingColor(context).withOpacity(0.08)
                          : OrderStatus.canceled.name == order.trackModel!.orderStatus ? Theme.of(context).colorScheme.error.withOpacity(0.08) : ColorResources.colorGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getTranslated(order.trackModel!.orderStatus, context),
                      style: rubikRegular.copyWith(color: OrderStatus.pending.name == order.trackModel!.orderStatus ? ColorResources.colorBlue
                          : OrderStatus.out_for_delivery.name == order.trackModel!.orderStatus ? ColorResources.getRatingColor(context)
                          : OrderStatus.canceled.name == order.trackModel!.orderStatus ? Theme.of(context).colorScheme.error : ColorResources.colorGreen),
                    ),
                  ),

                ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(DateConverterHelper.localDateToISOAMPMString(DateConverterHelper.convertStringToDatetime(orderProvider.trackModel!.createdAt!)), style: rubikRegular),

              ]),
            ),

            ((order.trackModel!.orderType == 'delivery') && (splashProvider.configModel?.googleMapStatus ?? false) &&
                (orderProvider.trackModel?.deliveryAddress?.longitude?.isNotEmpty ?? false) &&
                (orderProvider.trackModel?.deliveryAddress?.latitude?.isNotEmpty ?? false)
            ) ? InkWell(
              onTap: () {
                if(order.trackModel!.deliveryAddress != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MapWidget(address: order.trackModel!.deliveryAddress)));
                }
                else{
                  showCustomSnackBar('Address not found', context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(width: 1.5, color: Theme.of(context).primaryColor.withOpacity(0.1)),
                ),
                child: Row(children: [

                  Image.asset(Images.deliveryAddressIcon, color: Theme.of(context).primaryColor, height: 20, width: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text(getTranslated('delivery_address', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),

                ]),
              ),
            ): order.trackModel!.orderType == 'pos' ? Text(getTranslated('pos_order', context), style: rubikMedium)
                : order.trackModel!.orderType == 'delivery' ? const SizedBox()
                : Text(getTranslated('self_pickup', context), style: rubikMedium),

          ]) : const SizedBox(),

          ResponsiveHelper.isDesktop(context) ? const SizedBox() : Column(children: [
            Row(children: [

              Text('${getTranslated('order_id', context)}:', style: rubikRegular),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text(order.trackModel!.id.toString(), style: rubikMedium),
              SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraSmall),

              const Expanded(child: SizedBox()),

              Text(DateConverterHelper.isoStringToLocalDateOnly(order.trackModel!.createdAt!), style: rubikRegular),

            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Row(children: [

              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: OrderStatus.pending.name == order.trackModel!.orderStatus ? ColorResources.colorBlue.withOpacity(0.08)
                      : OrderStatus.out_for_delivery.name == order.trackModel!.orderStatus ? ColorResources.getRatingColor(context).withOpacity(0.08)
                      : OrderStatus.canceled.name == order.trackModel!.orderStatus ? Theme.of(context).colorScheme.error.withOpacity(0.08) : ColorResources.colorGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getTranslated(order.trackModel!.orderStatus, context),
                  style: rubikRegular.copyWith(color: OrderStatus.pending.name == order.trackModel!.orderStatus ? ColorResources.colorBlue
                      : OrderStatus.out_for_delivery.name == order.trackModel!.orderStatus ? ColorResources.getRatingColor(context)
                      : OrderStatus.canceled.name == order.trackModel!.orderStatus ? Theme.of(context).colorScheme.error : ColorResources.colorGreen),
                ),
              ),


              const Expanded(child: SizedBox()),

              ((order.trackModel!.orderType == 'delivery') && (splashProvider.configModel?.googleMapStatus ?? false) &&
                  (orderProvider.trackModel?.deliveryAddress?.longitude?.isNotEmpty ?? false) &&
                  (orderProvider.trackModel?.deliveryAddress?.latitude?.isNotEmpty ?? false)
              ) ? InkWell(
                onTap: () {
                  if(order.trackModel!.deliveryAddress != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MapWidget(address: order.trackModel!.deliveryAddress)));
                  }
                  else{
                    showCustomSnackBar('Address not found', context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1.5, color: Theme.of(context).primaryColor.withOpacity(0.1)),
                  ),
                  child: Image.asset(Images.deliveryAddressIcon, color: Theme.of(context).primaryColor, height: 20, width: 20),
                ),
              ) : order.trackModel!.orderType == 'pos' ? Text(getTranslated('pos_order', context), style: rubikMedium)
                  : order.trackModel!.orderType == 'delivery' ? const SizedBox()
                  : Text(getTranslated('self_pickup', context), style: rubikMedium),

            ]),
          ]),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          /// Payment info
          Container(
            decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
            ) : null,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Align(
                        alignment: ResponsiveHelper.isDesktop(context) ? Alignment.center : Alignment.centerLeft,
                        child: Text(getTranslated('payment_info', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      const Divider(),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(children: [

                        Text(getTranslated('status', context), style: rubikRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(getTranslated(order.trackModel!.paymentStatus, context), style: rubikMedium),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      ResponsiveHelper.isDesktop(context) ? const SizedBox() : Row(children: [

                        Text(getTranslated('method', context), style: rubikRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(
                          (order.trackModel!.paymentMethod != null && order.trackModel!.paymentMethod!.isNotEmpty)
                              ? order.trackModel!.paymentMethod == 'cash_on_delivery' ? getTranslated('cash_on_delivery', context): '${order.trackModel!.paymentMethod![0].toUpperCase()}${order.trackModel!.paymentMethod!.substring(1).replaceAll('_', ' ')}'
                              : getTranslated('digital_payment', context),
                          style: rubikMedium,
                        ),

                      ]),
                      SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall),

                      Row(children: [

                        Text('${getTranslated(itemsQuantity > 1 ? 'items' : 'item', context)} :', style: rubikRegular),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(itemsQuantity.toString(), style: rubikMedium),

                      ]),

                    ]),

                    ResponsiveHelper.isDesktop(context) ? Row(children: [

                      Text(getTranslated('method', context), style: rubikRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text(
                        (order.trackModel!.paymentMethod != null && order.trackModel!.paymentMethod!.isNotEmpty)
                            ? order.trackModel!.paymentMethod == 'cash_on_delivery' ? getTranslated('cash_on_delivery', context): '${order.trackModel!.paymentMethod![0].toUpperCase()}${order.trackModel!.paymentMethod!.substring(1).replaceAll('_', ' ')}'
                            : getTranslated('digital_payment', context),
                        style: rubikMedium,
                      ),

                    ]) : const SizedBox(),

                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.orderDetails!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      margin: EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall,
                        right: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                        left: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(ResponsiveHelper.isDesktop(context) ? 0.05 : 0.1), spreadRadius: 1, blurRadius: 5)],
                        border: ResponsiveHelper.isDesktop(context) ? Border.all(width: 1, color: Theme.of(context).disabledColor.withOpacity(0.08)) : null,
                      ),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomImageWidget(
                            image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/''${order.orderDetails![index].productDetails!.image![0]}',
                            height: 70, width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: ResponsiveHelper.isDesktop(context) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            SizedBox(
                              width: 200,
                              child: Text(
                                order.orderDetails![index].productDetails!.name!,
                                style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            order.orderDetails![index].variation != null && order.orderDetails![index].variation!.isNotEmpty ? VariationView(
                              variationName: OrderHelper.getVariationType(
                                order.orderDetails![index].productDetails?.variations,
                                order.orderDetails![index].variation,
                              ),
                            ) :const SizedBox() ,

                            Row(children: [

                              Text('${getTranslated('quantity', context)} :', style: rubikRegular.copyWith(color: Theme.of(context).disabledColor)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(order.orderDetails![index].quantity.toString(), style: rubikMedium.copyWith(color: Theme.of(context).disabledColor)),

                            ]),

                            Row(children: [

                              order.orderDetails![index].discountOnProduct! > 0 ? CustomDirectionalityWidget(
                                child: Text(
                                  PriceConverterHelper.convertPrice(order.orderDetails![index].price),
                                  style: rubikRegular.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: ColorResources.colorGrey,
                                  ),
                                ),
                              ) : const SizedBox(),
                              SizedBox(width: order.orderDetails![index].discountOnProduct! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                              CustomDirectionalityWidget(
                                child: Text(
                                  PriceConverterHelper.convertPrice(order.orderDetails![index].price! - order.orderDetails![index].discountOnProduct!),
                                  style: rubikBold,
                                ),
                              ),

                            ]),


                          ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Row(children: [
                              Expanded(
                                child: Text(
                                  order.orderDetails![index].productDetails!.name!,
                                  style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Row(children: [

                              Text('${getTranslated('quantity', context)} :', style: rubikRegular.copyWith(color: Theme.of(context).disabledColor)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(order.orderDetails![index].quantity.toString(), style: rubikMedium.copyWith(color: Theme.of(context).disabledColor)),

                            ]),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Row(children: [

                              order.orderDetails![index].discountOnProduct! > 0 ? CustomDirectionalityWidget(
                                child: Text(
                                  PriceConverterHelper.convertPrice(order.orderDetails![index].price),
                                  style: rubikRegular.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: ColorResources.colorGrey,
                                  ),
                                ),
                              ) : const SizedBox(),
                              SizedBox(width: order.orderDetails![index].discountOnProduct! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                              CustomDirectionalityWidget(
                                child: Text(
                                  PriceConverterHelper.convertPrice(order.orderDetails![index].price! - order.orderDetails![index].discountOnProduct!),
                                  style: rubikBold,
                                ),
                              ),

                            ]),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            order.orderDetails![index].variation != null && order.orderDetails![index].variation!.isNotEmpty ? VariationView(
                              variationName: OrderHelper.getVariationType(
                                order.orderDetails![index].productDetails?.variations,
                                order.orderDetails![index].variation,
                              ),
                            ) :const SizedBox() ,

                          ]),
                        ),
                      ]),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          (order.trackModel!.orderNote != null && order.trackModel!.orderNote!.isNotEmpty) ? Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge, top: Dimensions.paddingSizeSmall),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1, color: Theme.of(context).dividerColor),
            ),
            child: Text(order.trackModel!.orderNote!, style: rubikRegular.copyWith(color: Theme.of(context).hintColor)),
          ) : const SizedBox(),
        ]);
      }
    );
  }
}

class VariationView extends StatelessWidget {
  final String? variationName;
  const VariationView({Key? key, this.variationName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if(variationName != null) Container(height: 10, width: 10, decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      )),
      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

      Text(variationName ?? '',
        style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),
    ]);
  }
}
