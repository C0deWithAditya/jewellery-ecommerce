import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonWidget extends StatelessWidget {
  final OrderProvider order;
  const ButtonWidget({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();


    return Column(
      children: [
        !order.showCancelled ? Center(
          child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Row(children: [
              order.trackModel!.orderStatus == 'pending' ? Expanded(child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(1, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50), side: BorderSide(width: 2, color: Theme.of(context).hintColor.withOpacity(0.4))),
                  ),
                  onPressed: () {


                    ResponsiveHelper.showDialogOrBottomSheet(context, Consumer<OrderProvider>(
                      builder: (context, orderProvider, _) {
                        return CustomAlertDialogWidget(
                          title: getTranslated('are_you_sure_to_cancel', context),
                          icon: Icons.contact_support_outlined,
                          isLoading: orderProvider.isLoading,
                          onPressRight: (){
                            orderProvider.cancelOrder('${order.trackModel!.id}', (String message, bool isSuccess, String orderID) {
                              Navigator.pop(context);

                              if (isSuccess) {
                                productProvider.getLatestProductList(1, isUpdate: true);
                                orderProvider.getOrderList(context);
                                showCustomSnackBar('$message. Order ID: $orderID', context, isError: false);
                              } else {
                                showCustomSnackBar(message, context);
                              }
                            });
                          },

                        );
                      }
                    ));
                  },
                  child: Text(getTranslated('cancel_order', context), style: rubikRegular.copyWith(
                    color: Theme.of(context).hintColor.withOpacity(0.4),
                    fontSize: Dimensions.fontSizeLarge,
                  )),
                ),
              )) : const SizedBox(),

            ]),
          ),
        ) :
        Container(
          width: Dimensions.webScreenWidth,
          height: 50,
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(getTranslated('order_cancelled', context), style: rubikBold.copyWith(color: Theme.of(context).primaryColor)),
        ),

        (order.trackModel!.orderStatus == 'confirmed' || order.trackModel!.orderStatus == 'processing'
            || order.trackModel!.orderStatus == 'out_for_delivery') ? Center(
          child: Container(
            width: Dimensions.webScreenWidth,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: CustomButtonWidget(
              radius: Dimensions.radiusSizeFifty,
              btnTxt: getTranslated('track_order', context),
              onTap: () {
                RouteHelper.getOrderTrackingRoute(context, order.trackModel!.id,null, action: RouteAction.push);
              },
            ),
          ),
        ) : const SizedBox(),
        if(order.trackModel!.deliveryMan != null && (order.trackModel!.orderStatus != 'delivered') && isLoggedIn)
          Center(
            child: Container(
              width:  double.infinity ,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomButtonWidget(
                radius: Dimensions.radiusSizeFifty,
                  btnTxt: getTranslated('chat_with_delivery_man', context), onTap: (){

                RouteHelper.getChatRoute(context,
                  orderId: order.trackModel?.id,
                  userName: "${order.trackModel?.deliveryMan?.fName ??"" } ${order.trackModel?.deliveryMan?.lName??"" }",
                  profileImage: order.trackModel?.deliveryMan?.image ?? "",
                  action: RouteAction.push,
                );
              }),
            ),
          ),

        (order.trackModel!.orderStatus == 'delivered' && order.trackModel!.orderType != 'pos') && isLoggedIn ? Center(
          child: Container(
            width: Dimensions.webScreenWidth,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: CustomButtonWidget(
              radius: Dimensions.radiusSizeFifty,
              btnTxt: getTranslated('review', context),
              onTap: () {

                RouteHelper.getRateReviewRoute(context,
                  order.trackModel!.id.toString(),
                  order.trackModel!.deliveryMan!,
                  _getOrderDetailsList(orderList: order.orderDetails),
                  action: RouteAction.push,
                );


              },
            ),
          ),
        ) : const SizedBox(),
      ],
    );
  }

  List<OrderDetailsModel> _getOrderDetailsList({required  List<OrderDetailsModel>? orderList}){
    List<OrderDetailsModel> orderDetailsList = [];
    List<int?> orderIdList = [];

    if(orderList != null){
      for (OrderDetailsModel orderDetails in orderList) {
        if(orderDetails.productDetails != null) {
          if(!orderIdList.contains(orderDetails.productDetails!.id)) {
            orderDetailsList.add(orderDetails);
            orderIdList.add(orderDetails.productDetails!.id);
          }
        }
      }
    }
    return orderDetailsList;
  }
}