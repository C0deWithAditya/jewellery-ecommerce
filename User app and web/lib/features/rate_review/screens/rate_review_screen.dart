
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/features/rate_review/widgets/deliver_man_review_widget.dart';
import 'package:hexacom_user/features/rate_review/widgets/product_review_widget.dart';
import 'package:provider/provider.dart';

class RateReviewScreen extends StatefulWidget {
  final List<OrderDetailsModel>? orderDetailsList;
  final DeliveryMan? deliveryMan;
  final int? orderId;
  const RateReviewScreen({Key? key, required this.orderDetailsList, required this.deliveryMan, this.orderId}) : super(key: key);

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.deliveryMan == null ? 1 : 2, initialIndex: 0, vsync: this);

    Provider.of<RateReviewProvider>(context, listen: false).initRatingData(widget.orderDetailsList!);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('rate_review', context)),
      body: Column(children: [
        Center(child: Container(
          width: Dimensions.webScreenWidth,
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).textTheme.bodyLarge!.color,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            unselectedLabelStyle: rubikRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
            labelStyle: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            tabs: widget.deliveryMan == null ? [
              Tab(text: getTranslated((widget.orderDetailsList?.length ?? 0) > 1 ? 'items' : 'item', context)),
            ] : [
              Tab(text: getTranslated((widget.orderDetailsList?.length ?? 0) > 1 ? 'items' : 'item', context)),

              Tab(text: getTranslated('delivery_man', context)),
            ] ,
          ),
        )),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: widget.deliveryMan == null ?
          [
            ProductReviewWidget(orderDetailsList: widget.orderDetailsList),
          ]
              : [
            ProductReviewWidget(orderDetailsList: widget.orderDetailsList),
            DeliveryManReviewWidget(deliveryMan: widget.deliveryMan, orderID: widget.orderId.toString()),
          ] ,
        )),

    ]),
    );
  }
}
