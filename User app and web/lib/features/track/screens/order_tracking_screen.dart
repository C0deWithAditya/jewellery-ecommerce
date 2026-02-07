// import 'package:hexacom_user/common/enums/footer_type_enum.dart';
// import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
// import 'package:hexacom_user/features/track/providers/order_map_provider.dart';
// import 'package:hexacom_user/helper/price_converter_helper.dart';
// import 'package:hexacom_user/helper/responsive_helper.dart';
// import 'package:hexacom_user/localization/language_constrants.dart';
// import 'package:hexacom_user/main.dart';
// import 'package:hexacom_user/features/address/providers/address_provider.dart';
// import 'package:hexacom_user/features/order/providers/payment_provider.dart';
// import 'package:hexacom_user/utill/dimensions.dart';
// import 'package:hexacom_user/utill/routes.dart';
// import 'package:hexacom_user/utill/styles.dart';
// import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
// import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
// import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
// import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
// import 'package:hexacom_user/features/order/widgets/custom_stepper_widget.dart';
// import 'package:hexacom_user/features/order/widgets/delivery_man_widget.dart';
// import 'package:hexacom_user/features/order/widgets/tracking_map_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class OrderTrackingScreen extends StatefulWidget {
//   final String? orderID;
//   final bool fromOrderList;
//   const OrderTrackingScreen({Key? key, required this.orderID, required this.fromOrderList}) : super(key: key);
//
//   @override
//   State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
// }
//
// class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
//
//   @override
//   void initState() {
//
//     Provider.of<AddressProvider>(context, listen: false).initAddressList();
//     Provider.of<OrderProvider>(context, listen: false).getDeliveryManData(widget.orderID);
//     Provider.of<OrderProvider>(context, listen: false).getTrackOrder(widget.orderID, null, true);
//     Provider.of<OrderProvider>(context, listen: false).updateDeliveryManData(widget.orderID);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     Provider.of<OrderProvider>(Get.context!, listen: false).cancelTimer();
//     Provider.of<OrderMapProvider>(Get.context!, listen: false).disposeGoogleMapController();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//
//     final List<String> statusList = ['pending', 'confirmed', 'processing' ,'out_for_delivery', 'delivered', 'returned', 'failed', 'canceled'];
//
//     return Scaffold(
//       appBar: CustomAppBarWidget(title: getTranslated('order_tracking', context)),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             ConstrainedBox(
//               constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && size.height < 600 ? size.height : size.height - 400),
//               child: Padding(
//                 padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
//                 child: Consumer<OrderProvider>(
//                   builder: (context, order, child) {
//                     String? status;
//                     if(order.trackModel != null) {
//                       status = order.trackModel!.orderStatus;
//                     }
//
//                     if(status != null && status == statusList[5] || status == statusList[6] || status == statusList[7]) {
//                       return Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(status!),
//                           const SizedBox(height: 50),
//                           CustomButtonWidget(btnTxt: getTranslated('back_home', context), onTap: () {
//
//                             RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
//                           }),
//                         ],
//                       );
//                     } else if(order.responseModel != null && !order.responseModel!.isSuccess) {
//                       return Center(child: Text(order.responseModel!.message!));
//                     }
//
//                     return status != null ? RefreshIndicator(
//                       color: Theme.of(context).secondaryHeaderColor,
//                       onRefresh: () async {
//                         final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
//
//                         await orderProvider.getDeliveryManData(widget.orderID);
//                         await orderProvider.getTrackOrder(widget.orderID, null, true);
//                       },
//                       backgroundColor: Theme.of(context).primaryColor,
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             Center(
//                               child: Container(
//                                 padding: size.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
//                                 decoration: size.width > 700 ? BoxDecoration(
//                                   color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
//                                   boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
//                                 ) : null,
//                                 child: SizedBox(
//                                   width: Dimensions.webScreenWidth,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//                                           color: Theme.of(context).cardColor,
//                                           boxShadow: [
//                                             BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 0.5, blurRadius: 0.5)
//                                           ],
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Expanded(
//                                               child: Text('${getTranslated('order_id', context)} #${order.trackModel!.id}',
//                                                   style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
//                                             ),
//
//                                             CustomDirectionalityWidget(
//                                               child: Text(
//                                                 '${getTranslated('amount', context)} : ${PriceConverterHelper.convertPrice(order.trackModel!.orderAmount)}',
//                                                 style: rubikRegular,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                                       order.trackModel!.deliveryAddress != null ? Container(
//                                         padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeSmall),
//                                         decoration: BoxDecoration(
//                                           color: Theme.of(context).cardColor,
//                                           borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//                                           boxShadow: [
//                                             BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 0.5, blurRadius: 0.5)
//                                           ],
//                                         ),
//                                         child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                                           Icon(Icons.location_on, color: Theme.of(context).primaryColor),
//                                           const SizedBox(width: 20),
//
//                                           Expanded(
//                                             child: Text(
//                                               order.trackModel!.deliveryAddress != null? order.trackModel!.deliveryAddress!.address! : getTranslated('address_was_deleted', context),
//                                               style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
//                                             ),
//                                           ),
//                                         ]),
//                                       ) : const SizedBox(),
//
//                                       const SizedBox(height: Dimensions.paddingSizeLarge),
//
//                                       order.trackModel!.deliveryMan != null ? DeliveryManWidget(deliveryMan: order.trackModel!.deliveryMan) : const SizedBox(),
//                                       order.trackModel!.deliveryMan != null ? const SizedBox(height: 30) : const SizedBox(),
//
//                                       CustomStepperWidget(
//                                         title: getTranslated('order_placed', context),
//                                         isActive: true,
//                                         haveTopBar: false,
//                                       ),
//                                       CustomStepperWidget(
//                                         title: getTranslated('order_accepted', context),
//                                         isActive: status != statusList[0],
//                                       ),
//                                       CustomStepperWidget(
//                                         title: getTranslated('preparing_food', context),
//                                         isActive: status != statusList[0] && status != statusList[1],
//                                       ),
//                                       order.trackModel!.deliveryAddress != null ? CustomStepperWidget(
//                                         title: getTranslated('food_in_the_way', context),
//                                         isActive: status != statusList[0] && status != statusList[1] && status != statusList[2],
//                                       ) : const SizedBox(),
//                                       (order.trackModel != null && order.trackModel!.deliveryAddress != null) ?
//                                       CustomStepperWidget(
//                                         title: getTranslated('delivered_the_food', context),
//                                         isActive: status == statusList[4],
//                                         height: status == statusList[3] ? 240 : 30,
//                                         child: status == statusList[3] && !order.isLoading ? Flexible(
//                                           child: order.deliveryManModel != null ?  TrackingMapWidget(
//                                               orderID: widget.orderID,
//                                               addressModel: order.trackModel!.deliveryAddress
//                                           ) :
//                                           Container(
//                                             height: 200, width: MediaQuery.of(context).size.width - 100,
//                                             margin: const EdgeInsets.all(20),
//                                             padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                                             alignment: Alignment.center,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius: BorderRadius.circular(10),
//                                             ),
//                                             child: Text(getTranslated('no_delivery_man_data_found', context)),
//                                           ),
//                                         ) : null,
//                                       ) : CustomStepperWidget(
//                                         title: getTranslated('delivered_the_food', context),
//                                         isActive: status == statusList[4], height: status == statusList[3] ? 30 : 30,
//                                       ),
//                                       const SizedBox(height: 50),
//
//
//                                       Center(
//                                           child: SizedBox(
//                                             width: ResponsiveHelper.isDesktop(context) ?  400 : size.width,
//                                             child: CustomButtonWidget(btnTxt: getTranslated('back_home', context), onTap: () {
//                                               RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
//                                             }),
//                                           )
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ) : Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor));
//                   },
//                 ),
//               ),
//             ),
//             const FooterWebWidget(footerType: FooterType.nonSliver),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
