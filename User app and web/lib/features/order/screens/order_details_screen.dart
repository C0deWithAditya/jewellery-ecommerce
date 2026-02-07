import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/button_widget.dart';
import '../widgets/item_price_widget.dart';
import '../widgets/order_info_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final String? userPhoneNumber;
  final int? orderId;
  final bool isFromTrackOrderPage;
  const OrderDetailsScreen({super.key, required this.orderModel, required this.orderId, this.isFromTrackOrderPage = false, this.userPhoneNumber});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffold = GlobalKey();

  void _loadData(BuildContext context) async {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final AddressProvider locationProvider = Provider.of<AddressProvider>(context, listen: false);

    await orderProvider.getTrackOrder(widget.orderId.toString(), widget.orderModel, false);
    if(widget.orderModel == null) {
      await splashProvider.initConfig();
    }
    await locationProvider.initAddressList();
    print('-----(ORDER DETAILS)-----${widget.isFromTrackOrderPage} and ${widget.userPhoneNumber}');

    String? phone = widget.userPhoneNumber;

    if(!(phone?.contains('+') ?? false)){
      phone = '+${phone?.trim()}';
    }
    orderProvider.getOrderDetails(widget.orderId.toString(), phoneNumber: widget.isFromTrackOrderPage ? phone : null);
  }
  @override
  void initState() {
    super.initState();

    _loadData(context);
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffold,
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) : CustomAppBarWidget(title: getTranslated('order_details', context))) as PreferredSizeWidget?,
      body: SafeArea(
        child: Consumer<OrderProvider>(
          builder: (context, order, child) {
            double? deliveryCharge = 0;
            double itemsPrice = 0;
            double discount = 0;
            double extraDiscount = 0;
            double tax = 0;
            if(order.orderDetails != null && order.orderDetails!.isNotEmpty ) {
              if(order.trackModel?.orderType == 'delivery') {
                deliveryCharge = order.trackModel?.deliveryCharge;
              }
              for(OrderDetailsModel orderDetails in order.orderDetails!) {
                itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
                discount = discount + (orderDetails.discountOnProduct! * orderDetails.quantity!);
                tax = tax + (orderDetails.taxAmount! * orderDetails.quantity!);
              }
            }

            if( order.trackModel != null &&  order.trackModel!.extraDiscount!=null) {
              extraDiscount  = order.trackModel!.extraDiscount ?? 0.0;
            }

            double subTotal = itemsPrice + tax;
            double total = subTotal - discount - extraDiscount + deliveryCharge! - (order.trackModel != null ? order.trackModel!.couponDiscountAmount! : 0);

            return order.orderDetails == null || order.trackModel == null ? Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
            ) : order.orderDetails!.isNotEmpty ? Column(children: [
                Expanded(child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                            child: SizedBox(
                              width: Dimensions.webScreenWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if(ResponsiveHelper.isDesktop(context)) const Flexible(
                                        flex: 6,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                                          child: OrderInfoWidget(),
                                        ),
                                      ),
                                      if(ResponsiveHelper.isDesktop(context)) const SizedBox(width: Dimensions.paddingSizeLarge),

                                      if(ResponsiveHelper.isDesktop(context)) Flexible(
                                        flex: 4,
                                        child: Container(
                                          margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
                                          ),
                                          child: Column(
                                            children: [
                                              ItemPriceWidget(
                                                itemsPrice: itemsPrice, tax:  tax,subTotal: subTotal,
                                                discount: discount, order: order, deliveryCharge: deliveryCharge,
                                                total: total,extraDiscount: extraDiscount,
                                              ),

                                              ButtonWidget(order: order),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if(!ResponsiveHelper.isDesktop(context)) const OrderInfoWidget(), // Total
                                  if(!ResponsiveHelper.isDesktop(context)) ItemPriceWidget(itemsPrice: itemsPrice, tax:  tax,subTotal: subTotal, discount: discount, order: order, deliveryCharge: deliveryCharge, total: total,extraDiscount: extraDiscount,),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                        const FooterWebWidget(footerType: FooterType.nonSliver),
                      ],
                    ),
                  )),

                if(!ResponsiveHelper.isDesktop(context)) ButtonWidget(order: order),
              ]) : const NoDataScreen(showFooter: true);
          },
        ),
      ),
    );
  }
}







