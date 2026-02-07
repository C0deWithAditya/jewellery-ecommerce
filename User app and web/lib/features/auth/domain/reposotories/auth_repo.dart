import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/domain/models/social_login_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/signup_model.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;

  AuthRepo({required this.dioClient, required this.sharedPreferences});
  String? smsModule;


  Future<ApiResponseModel> registration(SignUpModel signUpModel) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.registerUri,
        data: signUpModel.toJson(),
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> login({required String userInput, String? password, String? type}) async {

    try {

      print('-------------(LOGIN REPO)-------$userInput, $password and $type}');

      Response response = await dioClient!.post(
        AppConstants.loginUri,
        data: {"email_or_phone": userInput, "password": password, "type" : type},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  //phone login
  Future<ApiResponseModel> loginByPhone({String? phone, String? password}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.loginUri,
        data: {"phone": phone, "password": password},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }



  Future<ApiResponseModel> updateToken({String? fcmToken}) async {
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

      if(!kIsWeb){
        if(fcmToken == null) {
          FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
        }else{
          FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
        }
      }else{
        print('--------(I am WEB AND)------${AppConstants.topic} and ${fcmToken}');
       await subscribeTokenToTopic(deviceToken, fcmToken ?? AppConstants.topic);
      }

      Response response = await dioClient!.post(
        AppConstants.tokenUri,
        data: {"_method": "put", "cm_firebase_token": fcmToken ?? deviceToken},
      );

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<void> subscribeTokenToTopic(token, topic) async {
    print("Topic ===>> $topic");
    print("Token ===>> $token");
     await dioClient?.post(AppConstants.subscribeToTopic, data: {"token": '$token', "topic": topic});
  }

  Future<String?> getDeviceToken() async {
    String? deviceToken = '@';
    try{
      deviceToken = (await FirebaseMessaging.instance.getToken())!;

    }catch(error){
      debugPrint('eroor ====> $error');
    }
    if (deviceToken != null) {
      debugPrint('--------Device Token---------- $deviceToken');
    }

    return deviceToken;
  }

  // for forgot password email
  Future<ApiResponseModel> forgetPassword(String userInput, String type) async {

    print("------------(FORGET API)-----------$userInput and $type}");

    try {
      Response response = await dioClient!.post(AppConstants.forgetPasswordUri, data: {"email_or_phone": userInput, "type": type});
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> verifyToken(String? email, String token) async {
    try {
      Response response = await dioClient!.post(AppConstants.verifyTokenUri, data: {"email_or_phone": email, "email": email, "reset_token": token});
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> resetPassword(String? userInput, String? resetToken, String password, String confirmPassword, {required String type}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.resetPasswordUri,
        data: {"_method": "put", "reset_token": resetToken, "password": password, "confirm_password": confirmPassword, "email_or_phone": userInput, "type": type},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // for verify Email
  Future<ApiResponseModel> sendVerificationCode(String? emailOrPhone, VerificationType verificationType) async {
    try {
      Response response = await dioClient!.post(
        verificationType == VerificationType.email ? AppConstants.checkEmailUri : AppConstants.checkPhoneUri,
        data:  {verificationType == VerificationType.email ? "email" : "phone": emailOrPhone},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> verifyVerificationCode(String phoneOrEmail, String token, VerificationType verificationType) async {
    try {
      Response response = await dioClient!.post(
        verificationType == VerificationType.phone ?  AppConstants.verifyPhoneUri : AppConstants.verifyEmailUri,
        data: {verificationType == VerificationType.phone ? "phone" : "email" : phoneOrEmail.trim(), "token": token},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> verifyOtp(String phone, String token) async {
    try {
      Response response = await dioClient!.post(
          AppConstants.verifyOtpUri, data: {"phone": phone.trim(), "token": token});
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> registerWithOtp(String name, {String? email, required String phone}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.registerWithOtp,
        data: {"name": name, "email": email, "phone": phone},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> registerWithSocialMedia(String name, {required String email, String? phone}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.registerWithSocialMedia,
        data: {"name": name, "email": email, "phone": phone},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> existingAccountCheck({required String email, required int userResponse, required String medium}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.existingAccountCheck,
        data: {"email": email, "user_response": userResponse, "medium": medium},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> verifyProfileInfo(String userInput, String token, String type, String? session) async {
    try {
      Response response = await dioClient!.post(
          AppConstants.verifyProfileInfo, data: {"email_or_phone": userInput, "token": token, "type": type, 'sessionInfo' : session});
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> firebaseAuthVerify({required String phoneNumber, required String session, required String otp, required bool isForgetPassword}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.firebaseAuthVerify,
        data: {
          'sessionInfo' : session,
          'phoneNumber' : phoneNumber,
          'code' : otp,
          'is_reset_token' : isForgetPassword ? 1 : 0,
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<void> saveGuestId(String id) async {
    try {
      sharedPreferences!.setString(AppConstants.guestId, id);
      dioClient?.updateHeader(getToken: sharedPreferences?.getString(AppConstants.token));

    } catch (e) {
      rethrow;
    }
  }

  String? getGuestId()=> sharedPreferences?.getString(AppConstants.guestId);

  // for  user token
  Future<void> saveUserToken(String token) async {
    dioClient!.updateHeader(getToken: token);

    try {
      await sharedPreferences!.setString(AppConstants.token, token);
    } catch (e) {
      rethrow;
    }
  }

  String getUserToken() {
    return sharedPreferences!.getString(AppConstants.token) ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences!.containsKey(AppConstants.token);
  }

  Future<bool> clearSharedData() async {
    await updateToken(fcmToken: '@');
    await sharedPreferences!.remove(AppConstants.token);
    await sharedPreferences!.remove(AppConstants.cartList);
    await sharedPreferences!.remove(AppConstants.userAddress);
    await sharedPreferences!.remove(AppConstants.searchAddress);
    dioClient?.updateHeader(getToken: null);
    return true;
  }

  Future<void> saveUserData (String userData) async {
    try {
      await sharedPreferences!.setString(AppConstants.userLogData, userData);
    } catch (e) {
      rethrow;
    }
  }

  String getUserData (){
    return sharedPreferences?.getString(AppConstants.userLogData) ?? '';
  }

  Future<bool> clearUserData() async {
    return await sharedPreferences!.remove(AppConstants.userLogData);
  }

  Future<ApiResponseModel> deleteUser() async {
    try{
      Response response = await dioClient!.delete(AppConstants.customerRemove);
      return ApiResponseModel.withSuccess(response);
    }catch(e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }

  }


  Future<ApiResponseModel> socialLogin(SocialLoginModel socialLogin) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.socialLogin,
        data: socialLogin.toJson(),
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> addOrUpdateGuest(String? fcmToken,) async {
    try{
      Response response = await dioClient!.post(AppConstants.addGuest, data: {
        'fcm_token': fcmToken,
        'guest_id' : getGuestId() == 'null' ? null : getGuestId(),
      });
      return ApiResponseModel.withSuccess(response);
    }catch(e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }

  }
}
