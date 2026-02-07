import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/order/widgets/order_item_widget.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/features/order/widgets/order_shimmer_widget.dart';
import 'package:provider/provider.dart';

class OrderListWidget extends StatelessWidget {
  final bool isRunning;
  const OrderListWidget({Key? key, required this.isRunning}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Consumer<OrderProvider>(
        builder: (context, order, index) {
          List<OrderModel>? orderList;
          if(order.runningOrderList != null) {
            orderList = isRunning ? order.runningOrderList!.reversed.toList() : order.historyOrderList!.reversed.toList();
          }

          return orderList != null ? orderList.isNotEmpty ? RefreshIndicator(
            color: Theme.of(context).secondaryHeaderColor,
            onRefresh: () async {
              await Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 450),
                      child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                          itemCount: orderList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return  Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                              child: OrderItemWidget(orderList: orderList, index: index, isRunning : isRunning),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const FooterWebWidget(footerType: FooterType.nonSliver),

                ],
              ),
            ),
          ) : NoDataScreen(
            image: Images.noOrderImage ,
            title: getTranslated('no_order_history_available', context),
            subTitle: getTranslated('buy_something_to_see', context),
            showFooter: true,
            scrollable: true,
          ) : const OrderShimmerWidget();
        },
      ),
    );
  }
}


