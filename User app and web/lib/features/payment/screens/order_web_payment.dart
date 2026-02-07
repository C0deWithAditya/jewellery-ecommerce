import 'dart:convert';
import 'package:hexacom_user/common/models/place_order_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderWebPayment extends StatefulWidget {
  final String? token;
  const OrderWebPayment({Key? key, this.token}) : super(key: key);

  @override
  State<OrderWebPayment> createState() => _OrderWebPaymentState();
}

class _OrderWebPaymentState extends State<OrderWebPayment> {

  getValue() async {
    if(html.window.location.href.contains('success')){
      try{
        final orderProvider =  Provider.of<OrderProvider>(context, listen: false);
        String placeOrderString =  utf8.decode(base64Url.decode(orderProvider.getPlaceOrderData()!.replaceAll(' ', '+')));
        String tokenString = utf8.decode(base64Url.decode(widget.token!.replaceAll(' ', '+')));
        String paymentMethod = tokenString.substring(0, tokenString.indexOf('&&'));
        String transactionReference = tokenString.substring(tokenString.indexOf('&&') + '&&'.length, tokenString.length);

        PlaceOrderModel placeOrderBody =  PlaceOrderModel.fromJson(jsonDecode(placeOrderString)).copyWith(
          paymentMethod: paymentMethod.replaceAll('payment_method=', ''),
          transactionReference:  transactionReference.replaceRange(0, transactionReference.indexOf('transaction_reference='), '').replaceAll('transaction_reference=', ''),
        );
        orderProvider.placeOrder(context, placeOrderBody, _callback);
      }catch(e){

        RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
      }

    }else{
      RouteHelper.getOrderSuccessScreen(context, '0', 'field');
    }
  }

  void _callback(BuildContext context, bool isSuccess, String message, String orderID) async {
    Provider.of<CartProvider>(context, listen: false).clearCartList();
    Provider.of<OrderProvider>(context, listen: false).clearPlaceOrderData();
    if(isSuccess) {
      RouteHelper.getOrderSuccessScreen(context, orderID, 'success');

    }else {
      showCustomSnackBar(message, context);
    }
  }

  @override
  void initState() {
    super.initState();
    getValue();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()): null,
      body: Center(
          child: CustomLoaderWidget(color: Theme.of(context).primaryColor)),
    );
  }
}
