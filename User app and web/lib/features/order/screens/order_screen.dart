import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/not_logged_in_screen.dart';
import 'package:hexacom_user/features/order/widgets/order_list_widget.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(_isLoggedIn) {
      _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
      Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('my_order', context)),
      body: _isLoggedIn ? Consumer<OrderProvider>(
        builder: (context, order, child) {
          return Column(children: [
            Center(child: Container(
              color: Theme.of(context).canvasColor,
              child: TabBar(
                tabAlignment: TabAlignment.center,
                controller: _tabController,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 3,
                unselectedLabelStyle: rubikRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                labelStyle: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                tabs: [
                  Tab(text: getTranslated('ongoing', context)),
                  Tab(text: getTranslated('history', context)),
                ],
              ),
            )),

            Expanded(child: TabBarView(
              controller: _tabController,
              children: const [
                OrderListWidget(isRunning: true),
                OrderListWidget(isRunning: false),
              ],
            )),

          ]);
        },
      ) : const NotLoggedInScreen(),
    );
  }
}
