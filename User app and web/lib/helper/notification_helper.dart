import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hexacom_user/common/models/notification_body.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/chat/providers/chat_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/features/notification/widgets/notifiation_popup_dialog_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class NotificationHelper {


  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        try{
          if(notificationResponse.payload!=null && notificationResponse.payload!=''){
            NotificationBody notificationBody = NotificationBody.fromJson(jsonDecode(notificationResponse.payload!));
            if (kDebugMode) {
              print("Notification Type => ${notificationBody.type}");
            }

            if(notificationBody.type == "message"){
             RouteHelper.getChatRoute(Get.context!, orderId: notificationBody.orderId, userName: notificationBody.userName, profileImage: notificationBody.userImage);
            } else if(notificationBody.type == "order"){
              RouteHelper.getOrderDetailsRoute(Get.context!, notificationBody.orderId, null);
            }else if(notificationBody.type == "general"){
              RouteHelper.getNotificationRoute(Get.context!, action: RouteAction.push);
            }else {
              RouteHelper.getMainRoute(Get.context!, action: RouteAction.pushNamedAndRemoveUntil);
            }

          }
        }catch (e) {
          if (kDebugMode) {
            print("");
          }
        }

        return;
      },);


    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      debugPrint("onMessage: Message Type => ${message.data['type']}/${message.data['title']}/${message.data['body']}");
      NotificationBody notificationBody = NotificationBody.fromJson(message.data);

      if(notificationBody.type == 'message') {
        var chatProvider = Provider.of<ChatProvider>(Get.context!, listen: false);
        if(chatProvider.currentRouteIsChat){
          chatProvider.getMessages(1, notificationBody.orderId , false);
        }else{
          showNotification(message, flutterLocalNotificationsPlugin, kIsWeb);
        }
      }

      else if(notificationBody.type == 'maintenance'){
        final SplashProvider splashProvider = Provider.of<SplashProvider>(Get.context!, listen: false);
        await splashProvider.initConfig(fromNotification: true);
      }

      else if(notificationBody.type == 'order'){
        Provider.of<OrderProvider>(Get.context!, listen: false).getTrackOrder(notificationBody.orderId.toString(), null, false);
      }

      if(message.data['type'] != 'maintenance' && notificationBody.type != "message"){
        showNotification(message, flutterLocalNotificationsPlugin, kIsWeb);
      }

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onMessageOpenApp: Message Type => ${message.data['type']}/${message.data['title']}/${message.data['body']}");
      NotificationBody notificationBody = NotificationBody.fromJson(message.data);
      if(notificationBody.type == "message"){
        RouteHelper.getChatRoute(Get.context!, orderId: notificationBody.orderId, userName: notificationBody.userName, profileImage: notificationBody.userImage);
      } else if(notificationBody.type == "order"){
        RouteHelper.getOrderDetailsRoute(Get.context!, notificationBody.orderId, null);
      }else if(notificationBody.type == "general"){
        RouteHelper.getNotificationRoute(Get.context!, action: RouteAction.push);
      }else {
        RouteHelper.getMainRoute(Get.context!, action: RouteAction.pushNamedAndRemoveUntil);
      }

    });

  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
    String? title;
    String? body;
    String? image;
    String playLoad = jsonEncode(message.data);

    title = message.data['title'];
    body = message.data['body'];
    image = (message.data['image'] != null && message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http') ? message.data['image']
        : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;
    if(kIsWeb) {


     Future.delayed(const Duration(milliseconds: 500), (){
       showDialog(
           context: Get.context!,
           builder: (context) => Center(
             child: NotificationPopUpDialogWidget(NotificationBody.fromJson(message.data)),
           )
       );
     });
    }

    if(image != null && image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(title, body, playLoad, image, fln);
      }catch(e) {
        await showBigTextNotification(title, body!, playLoad, fln);
      }
    }else {
      await showBigTextNotification(title, body!, playLoad, fln);
    }
  }


  static Future<void> showBigTextNotification(String? title, String body, String? orderID, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConstants.appName, AppConstants.appName, importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, String? orderID, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConstants.appName, AppConstants.appName,
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Response response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    final File file = File(filePath);
    await file.writeAsBytes(response.data);
    return filePath;
  }

  static NotificationBody convertNotification(Map<String, dynamic> data){
    return NotificationBody.fromJson(data);
  }
}


@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint("onBackground: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");

}

