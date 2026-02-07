import 'dart:convert';
import 'dart:io';
import 'package:emarket_delivery_boy/commons/models/notification_body.dart';
import 'package:emarket_delivery_boy/features/chat/providers/chat_provider.dart';
import 'package:emarket_delivery_boy/features/chat/screens/chat_screen.dart';
import 'package:emarket_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:emarket_delivery_boy/features/order/providers/order_provider.dart';
import 'package:emarket_delivery_boy/features/order/screens/order_details_screen.dart';
import 'package:emarket_delivery_boy/features/splash/providers/splash_provider.dart';
import 'package:emarket_delivery_boy/main.dart';
import 'package:emarket_delivery_boy/utill/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) async {
      try{
        if(notificationResponse!.payload!=null && notificationResponse.payload!=''){
          NotificationBody notificationBody = NotificationBody.fromJson(jsonDecode(notificationResponse.payload!));

          if (kDebugMode) {
            print("Notification Type => ${notificationBody.type}");
          }

          if(notificationBody.type == "message"){
            Get.navigator!.push(MaterialPageRoute(builder: (context) =>
                ChatScreen(
                  orderId: notificationBody.orderId,
                  userName: notificationBody.userName,
                  profileImage: notificationBody.image,
                ),
            ));
          } else if(notificationBody.type == "order"){
            Get.navigator!.push(MaterialPageRoute(builder: (context) =>
                OrderDetailsScreen(orderModelItem: OrderModel(id: notificationBody.orderId))),
            );

          }

        }
      }catch (e) {
        if (kDebugMode) {
          print("");
        }
      }
      return;
    });


    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      debugPrint("onMessage: Message Type => ${message.data['type']}/${message.data['title']}/${message.data['body']}/${message.data['order_id']}");

      NotificationBody notificationBody = NotificationBody.fromJson(message.data);

      if(notificationBody.type == "order"){
        Provider.of<OrderProvider>(Get.context!, listen: false).getAllOrders();
      }
      else  if(notificationBody.type == "maintenance"){
        final SplashProvider splashProvider = Provider.of<SplashProvider>(Get.context!, listen: false);
        await splashProvider.initConfig(Get.context!,fromNotification: true);
      }
      else  if(notificationBody.type == "message"){
        var chatProvider = Provider.of<ChatProvider>(Get.context!, listen: false);

        if(chatProvider.currentRouteIsChat){
          chatProvider.getChatMessages(notificationBody.orderId);
        }else{
          showNotification(message, flutterLocalNotificationsPlugin);
        }
      }

      if(notificationBody.type != 'maintenance' && notificationBody.type != "message"){
        showNotification(message, flutterLocalNotificationsPlugin);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onMessageOpenApp: Message Type => ${message.data['type']}/${message.data['title']}/${message.data['body']}");
      showNotification(message, flutterLocalNotificationsPlugin);
    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin? fln) async {
    String? title;
    String? body;
    String? image;
    String playLoad = jsonEncode(message.data);

    title = message.data['title'];
    body = message.data['body'];
    image = (message.data['image'] != null && message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http') ? message.data['image']
        : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;

    if(image != null && image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(title, body, playLoad, image, fln!);
      }catch(e) {
        await showBigTextNotification(title, body!, playLoad, fln!);
      }
    }else {
      await showBigTextNotification(title, body!, playLoad, fln!);
    }
  }

  static Future<void> showTextNotification(String title, String body, String orderID, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(

      AppConstants.appName, AppConstants.appName, playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
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
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
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