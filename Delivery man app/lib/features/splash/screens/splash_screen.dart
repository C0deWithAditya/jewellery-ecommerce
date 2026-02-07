import 'dart:async';
import 'package:emarket_delivery_boy/commons/models/notification_body.dart';
import 'package:emarket_delivery_boy/features/chat/screens/chat_screen.dart';
import 'package:emarket_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:emarket_delivery_boy/features/order/screens/order_details_screen.dart';
import 'package:emarket_delivery_boy/helper/maintenance_helper.dart';
import 'package:emarket_delivery_boy/main.dart';
import 'package:emarket_delivery_boy/utill/app_constants.dart';
import 'package:emarket_delivery_boy/utill/styles.dart';
import 'package:emarket_delivery_boy/features/maintenance/screens/maintenance_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:emarket_delivery_boy/localization/language_constrants.dart';
import 'package:emarket_delivery_boy/features/auth/providers/auth_provider.dart';
import 'package:emarket_delivery_boy/features/splash/providers/splash_provider.dart';
import 'package:emarket_delivery_boy/utill/images.dart';
import 'package:emarket_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:emarket_delivery_boy/features/language/screens/choose_language_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    _goRouteToPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Images.logo, width: 200),

            Text(AppConstants.appName, style: rubikBold.copyWith(fontSize: 30)),
          ],
        ),
      ),
    );
  }

  void _goRouteToPage() {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    splashProvider.initSharedData();
    Provider.of<SplashProvider>(context, listen: false).initConfig(context).then((bool isSuccess) {
      if (isSuccess) {
        if(MaintenanceHelper.isMaintenanceModeEnable(splashProvider.configModel)) {
          Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => const MaintenanceScreen()));
        }
        else if(widget.body != null){
          _notificationRoute();
        } else{
          Timer(const Duration(seconds: 1), () async {
            if (Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn()) {
              Provider.of<AuthProvider>(Get.context!, listen: false).updateToken();
              _checkPermission(const DashboardScreen());
            } else {
              _checkPermission(const ChooseLanguageScreen());
            }

          });
        }
      }
    });
  }
  void _notificationRoute(){
    String notificationType = widget.body?.type ?? "";
    if(notificationType == "message"){
      Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => ChatScreen(
        orderId: widget.body?.orderId,
        userName: widget.body?.userName,
        profileImage: widget.body?.image,
      )));
    }else if(notificationType == "order"){
      Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderModelItem: OrderModel(id: widget.body?.orderId))));
    }else{
      Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  void _checkPermission(Widget navigateTo) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showDialog(context: Get.context!, barrierDismissible: false, builder: (context) => AlertDialog(
        title: Text(getTranslated('alert', context)!),
        content: Text(getTranslated('allow_for_all_time', context)!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        actions: [ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await Geolocator.requestPermission();
            _checkPermission(navigateTo);
          },
          child: Text(getTranslated('ok', context)!),
        )],
      ));
    }else if(permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
    }else {
      Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => navigateTo));
    }
  }

}
