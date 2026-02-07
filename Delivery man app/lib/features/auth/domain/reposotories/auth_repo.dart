
import 'package:dio/dio.dart';
import 'package:emarket_delivery_boy/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:emarket_delivery_boy/data/datasource/remote/dio/dio_client.dart';
import 'package:emarket_delivery_boy/data/datasource/remote/exception/api_error_handler.dart';
import 'package:emarket_delivery_boy/commons/models/api_response.dart';
import 'package:emarket_delivery_boy/utill/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class AuthRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  AuthRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponse> login({String? emailAddress, String? password}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.loginUri,
        data: {"email": emailAddress, "password": password},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }



  // for  user token
  Future<void> saveUserToken(String token) async {
    dioClient!.token = token;
    dioClient!.dio!.options.headers = {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $token'};

    try {
      await sharedPreferences!.setString(AppConstants.token, token);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse> updateToken({String? token}) async {
    try {
      String? deviceToken = '@';
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
        NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
          alert: true, announcement: false, badge: true, carPlay: false,
          criticalAlert: false, provisional: false, sound: true,
        );
        if(settings.authorizationStatus == AuthorizationStatus.authorized) {
          deviceToken = (await getDeviceToken())!;
        }
      }else {
        deviceToken = (await getDeviceToken())!;
      }
      FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
      Response response = await dioClient!.post(
        AppConstants.tokenUri,
        data: {"_method": "put", "fcm_token": token ?? deviceToken, "token": sharedPreferences!.get(AppConstants.token)},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<String?> getDeviceToken() async {
    String? deviceToken = '@';
    try{
      deviceToken = (await FirebaseMessaging.instance.getToken())!;

    }catch(error){
      debugPrint('error ====> $error');
    }
    if (deviceToken != null) {
      debugPrint('--------Device Token---------- $deviceToken');
    }

    return deviceToken;
  }

  String getUserToken() {
    return sharedPreferences!.getString(AppConstants.token) ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences!.containsKey(AppConstants.token);
  }

  Future<bool> clearSharedData() async {
    return sharedPreferences!.remove(AppConstants.token);
  }

  // for  Remember Email
  Future<void> saveUserNumberAndPassword(String number, String password) async {
    try {
      await sharedPreferences!.setString(AppConstants.userPassword, password);
      await sharedPreferences!.setString(AppConstants.userEmail, number);
    } catch (e) {
      rethrow;
    }
  }

  String getUserEmail() {
    return sharedPreferences!.getString(AppConstants.userEmail) ?? "";
  }

  String getUserPassword() {
    return sharedPreferences!.getString(AppConstants.userPassword) ?? "";
  }

  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences!.remove(AppConstants.userPassword);
    return await sharedPreferences!.remove(AppConstants.userEmail);
  }

  Future<http.Response> registerDeliveryMan(DeliveryManBodyModel deliveryManBody, List<MultipartBody> multiParts) async {
    http.Response response = await dioClient!.postMultipartData(
      AppConstants.register,
      deliveryManBody.toJson(),
      multiParts,
    );
    return response;
  }

  Future<ApiResponse> deleteUser() async {
    try{
      Response response = await dioClient!.delete('${AppConstants.removeAccount}${sharedPreferences!.get(AppConstants.token)}');
      return ApiResponse.withSuccess(response);
    }catch(e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }

  }
}
