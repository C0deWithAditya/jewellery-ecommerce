// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/social_login_options_enum.dart';
import 'package:hexacom_user/features/auth/domain/models/social_login_model.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/error_response_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/models/userinfo_model.dart';
import 'package:hexacom_user/features/auth/domain/models/user_log_data.dart';
import 'package:hexacom_user/features/auth/domain/reposotories/auth_repo.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:provider/provider.dart';
import '../../../helper/api_checker_helper.dart';
import '../../../localization/language_constrants.dart';
import '../../../helper/custom_snackbar_helper.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepo? authRepo;

  AuthProvider({required this.authRepo});


  bool _isLoading = false;
  bool _isNumberLogin = false;
  bool _isForgotPasswordLoading = false;
  bool resendButtonLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
  bool _isAgreeTerms = false;
  int _countSocialLoginOptions = 0;
  String? _loginErrorMessage = '';
  String _email = '';
  String _phone = '';
  bool _isActiveRememberMe = false;



  bool get isLoading => _isLoading;
  bool get isNumberLogin => _isNumberLogin;
  bool get isForgotPasswordLoading => _isForgotPasswordLoading;
  GoogleSignInAccount? googleAccount;
  bool get isAgreeTerms => _isAgreeTerms;
  int get countSocialLoginOptions => _countSocialLoginOptions;
  String? get loginErrorMessage => _loginErrorMessage;
  String get email => _email;
  String get phone => _phone;
  bool get isActiveRememberMe => _isActiveRememberMe;
  bool isLoggedIn()=> authRepo!.isLoggedIn();


  updateEmail(String email) {
    _email = email;
    notifyListeners();
  }
  updatePhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    notifyListeners();
  }

  void saveUserData(UserLogData userLogData) {
    authRepo!.saveUserData(jsonEncode(userLogData.toJson()));
  }

  UserLogData? getUserData() {
    UserLogData? userData;
    try{
      userData = UserLogData.fromJson(jsonDecode(authRepo!.getUserData()));
    }catch(error) {
      debugPrint('error ====> $error');

    }
    return userData;
  }

  Future<bool> clearUserData() async {
    return authRepo!.clearUserData();
  }

  String getUserToken() {
    return authRepo!.getUserToken();
  }

  Future deleteUser() async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel response = await authRepo!.deleteUser();
    _isLoading = false;
    if (response.response!.statusCode == 200) {
      Provider.of<SplashProvider>(Get.context!, listen: false).removeSharedData();
      showCustomSnackBar(getTranslated('your_account_remove_successfully', Get.context!), Get.context!);
      RouteHelper.getLoginRoute(Get.context!, action: RouteAction.pushNamedAndRemoveUntil);
    }else{
      Navigator.of(Get.context!).pop();
      ApiCheckerHelper.checkApi(response);
    }
  }


  Future<ResponseModel> login(BuildContext buildContext, String userInput, String? password, String type, {required String fromPage}) async {

    final VerificationProvider verificationProvider = Provider.of<VerificationProvider>(Get.context!, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(Get.context!, listen: false);

    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();

    print('-------------(LOGIN)-----------$userInput, $password and $type');

    ApiResponseModel apiResponse = await authRepo!.login(userInput: userInput, password: password, type: type);
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      String? token;
      String? tempToken;
      Map map = apiResponse.response?.data;

      print("------------------------ API RESPONSE : ${map.toString()}-----------------------------");

      if(map.containsKey('temporary_token')) {
        tempToken = map["temporary_token"];
      }else if(map.containsKey('token')){
        token = map["token"];

      }
      if(token != null){
        await updateAuthToken(token);
        final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
        profileProvider.getUserInfo();
      }else if(tempToken != null){
        print("-----------------------(TEMP TOKEN) : User Input: $userInput , FromPage: $fromPage");
        await verificationProvider.sendVerificationCode(buildContext, splashProvider.configModel!, userInput, type: type, fromPage: fromPage);
      }
      responseModel = ResponseModel(token != null, 'verification');

    } else {

      _loginErrorMessage = ErrorResponseModel.fromJson(apiResponse.error).errors![0].message;
      responseModel = ResponseModel(false,_loginErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<void> updateToken() async {
    if(await authRepo!.getDeviceToken() != '@'){
      print('-----HERE AM I 2');
      await authRepo!.updateToken();
    }
  }

  Future<ResponseModel> forgetPassword(String userInput, String type) async {
    _isLoading = true;
    resendButtonLoading = true;
    notifyListeners();

    print("-------------------(FORGET PASSWORD)------------UserInput: $userInput------- and Type:$type");

    ApiResponseModel apiResponse = await authRepo!.forgetPassword(userInput, type);
    ResponseModel responseModel;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      responseModel = ResponseModel(false, ApiCheckerHelper.getError(apiResponse).errors?.first.message);
    }
    resendButtonLoading = false;
    _isLoading = false;
    notifyListeners();

    return responseModel;
  }

  Future<void> firebaseOtpLogin(BuildContext context, {required String phoneNumber, required String session, required String otp, bool isForgetPassword = false}) async {

    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!.firebaseAuthVerify(
      session: session, phoneNumber: phoneNumber,
      otp: otp, isForgetPassword: isForgetPassword,
    );

    print("---------------(FIREBASE OTP LOGIN)--------------$phoneNumber, $session, $otp, $isForgetPassword");


    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      String? token;
      String? tempToken;

      print("-------------(FIREBASE API)-----------${map.toString()}");

      try{
        token = map["token"];
        tempToken = map["temp_token"];
      }catch(error){
        print("Error $error");
      }

      if(isForgetPassword) {
        RouteHelper.getNewPassRoute(context, phoneNumber, otp, action: RouteAction.push);
      }else{
        if(token != null) {
          String? countryCode = PhoneNumberCheckerHelper.getCountryCode(phoneNumber);
          String? phone = PhoneNumberCheckerHelper.getPhoneNumber(phoneNumber, countryCode ?? '');
          await updateAuthToken(token);
          final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
          profileProvider.getUserInfo();
          saveUserData(UserLogData(
            countryCode: countryCode,
            phoneNumber: phone,
            email: null,
            password: null,
            loginType: FromPage.otp.name,
          ));
          RouteHelper.getMainRoute(context, action: RouteAction.pushReplacement);
        }else if(tempToken != null){
          RouteHelper.getOtpRegistrationScreen(context, tempToken, phoneNumber, action: RouteAction.pushReplacement);
        }
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ResponseModel> resetPassword(String? userInput, String? resetToken, String password, String confirmPassword, {required String type}) async {
    _isForgotPasswordLoading = true;
    notifyListeners();

    print("------------------------------------(RESET PASSWORD)----------------UserInput: $userInput, Reset Token: $resetToken, Password: $password, ConfirmPassword: $confirmPassword and Type: $type");

    ApiResponseModel apiResponse = await authRepo!.resetPassword(userInput, resetToken, password, confirmPassword, type: type);

    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      print("--------------------------(RESET PASSWORD)------------${apiResponse.response?.data}");
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      responseModel = ResponseModel(false, ApiCheckerHelper.getError(apiResponse).errors![0].message);
    }

    _isForgotPasswordLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<void> updateAuthToken(String token) async {
    authRepo?.saveUserToken(token);
    await authRepo?.updateToken();
  }

  Future<bool> clearSharedData() async {
    final WishListProvider wishListProvider = Provider.of<WishListProvider>(Get.context!, listen: false);
    final CartProvider cartProvider = Provider.of<CartProvider>(Get.context!, listen: false);
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);

    _isLoading = true;
    notifyListeners();
    bool isSuccess = await authRepo!.clearSharedData();

    await socialLogout();
    wishListProvider.clearWishList();
    cartProvider.getCartData(isUpdate: true);
    profileProvider.resetUserProfile(isUpdate: true);

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  Future<GoogleSignInAuthentication> googleLogin() async {
    GoogleSignInAuthentication auth;
    googleAccount = await _googleSignIn.signIn();
    auth = await googleAccount!.authentication;
    return auth;
  }

  Future<ResponseModel> registerWithOtp (BuildContext context, String name, {String? email, required String phone}) async{
    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();
    print("----------------------(REGISTER WITH OTP)----------- Email : $email , Phone: $phone , Name $name");
    ApiResponseModel apiResponse = await authRepo!.registerWithOtp(name, email: email, phone: phone);
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      print("----------------------(REGISTER WITH OTP)----------- API RESPONSE: ${apiResponse.response?.data}");
      String? token;
      Map map = apiResponse.response!.data;
      if(map.containsKey('token')){
        token = map["token"];
      }
      if(token != null){
        await updateAuthToken(token);
        final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
        profileProvider.getUserInfo();
      }
      responseModel = ResponseModel(token != null, 'verification');
    } else {
      _loginErrorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message;
      showCustomSnackBar(_loginErrorMessage ?? '', context);
      responseModel = ResponseModel(false, _loginErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<(ResponseModel, String?)> registerWithSocialMedia (BuildContext context, String name, {required String email, String? phone}) async{
    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!.registerWithSocialMedia(name, email: email, phone: phone);
    ResponseModel responseModel;
    String? token;
    String? tempToken;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      Map map = apiResponse.response!.data;
      if(map.containsKey('token')){
        token = map["token"];
      }
      if(map.containsKey('temp_token')){
        tempToken = map["temp_token"];
      }

      if(token != null){
        await updateAuthToken(token);
        final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
        profileProvider.getUserInfo();
        responseModel = ResponseModel(true, 'verification');
      }else if(tempToken != null){
        responseModel = ResponseModel(true, 'verification');
      }else{
        responseModel = ResponseModel(false, '');
      }

    } else {
      _loginErrorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message;
      showCustomSnackBar(_loginErrorMessage ?? '', context);
      responseModel = ResponseModel(false, _loginErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return (responseModel, tempToken);
  }

  Future<(ResponseModel?, String?)> existingAccountCheck (BuildContext context, {required String email, required int userResponse, required String medium}) async{
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!.existingAccountCheck(email: email, userResponse: userResponse, medium: medium);
    ResponseModel responseModel;
    String? token;
    String? tempToken;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {


      Map map = apiResponse.response!.data;

      if(map.containsKey('token')){
        token = map["token"];
      }

      if(map.containsKey('temp_token')){
        tempToken = map["temp_token"];
      }

      if(token != null){
        await updateAuthToken(token);
        final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
        profileProvider.getUserInfo();
        responseModel = ResponseModel(true, 'token');
      } else if(tempToken != null){
        responseModel = ResponseModel(true, 'tempToken');
      } else{
        responseModel = ResponseModel(true, '');
      }


    } else {
      _loginErrorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message;
      showCustomSnackBar(_loginErrorMessage ?? '', context);
      responseModel = ResponseModel(false, _loginErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return (responseModel, tempToken);
  }

  Future  socialLogin(SocialLoginModel socialLogin, Function callback) async {
    _isLoading = true;
    notifyListeners();
    print('-----------------(SOCIAL LOGIN API)---> ${socialLogin.toJson()}');
    ApiResponseModel apiResponse = await authRepo!.socialLogin(socialLogin);
    _isLoading = false;
    if (apiResponse.response?.statusCode == 200 && apiResponse.response != null) {
      print("-----------------------(SOCIAL LOGIN API)-----------${apiResponse.response?.data}");
      Map map = apiResponse.response?.data;
      String? message = '';
      String? token = '';
      String? tempToken = '';
      String? email;
      UserInfoModel? userInfoModel;

      try{
        message = map['error_message'] ?? '';
      }catch(e){
        debugPrint("Error :$e");
      }

      try{
        token = map['token'];
      }catch(e){
        debugPrint("Error :$e");
      }

      try{
        tempToken = map['temp_token'];
      }catch(e){
        debugPrint("Error :$e");
      }

      try{
        email = map['email'];
      }catch(e){
        debugPrint("Error :$e");
      }


      if(map.containsKey('user')){
        try{
          userInfoModel = UserInfoModel.fromJson(map['user']);
          print("--------------(SOCIAL Name)--------------${socialLogin.name}");
          print("--------------(SOCIAL Email)--------------${socialLogin.email}");
          print("--------------(SOCIAL Medium)--------------${socialLogin.medium}");
          callback(true, null, message, null, userInfoModel, socialLogin.medium, socialLogin.email, socialLogin.name);
        }catch(e){
          debugPrint("Error :$e");
        }
      }

      if(token != null){
        await updateAuthToken(token);
        final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
        profileProvider.getUserInfo();
        callback(true, token, message,null, null, null, null, null);
      }

      if(tempToken != null){
        print("--------------(SOCIAL)--------------${socialLogin.name}");
        callback(true, null, message, tempToken, null, null, socialLogin.email ?? email, socialLogin.name);
      }
      notifyListeners();
    }else {
      callback(false, '', ApiCheckerHelper.getError(apiResponse).errors?.first.message, null, null, null, null, null);
      notifyListeners();
    }
  }

  Future<void> socialLogout() async {
    final UserInfoModel user = Provider.of<ProfileProvider>(Get.context!, listen: false).userInfoModel!;
    if(user.loginMedium!.toLowerCase() == SocialLoginOptionsEnum.google.name) {
      try{
        // await _googleSignIn.signOut();
        await googleSignOut();
      }catch(e){
        log("Error: $e");
      }
    }else if(user.loginMedium!.toLowerCase() == SocialLoginOptionsEnum.facebook.name){
      await FacebookAuth.instance.logOut();
    }
  }

  Future<void> googleSignOut() async{
    await _googleSignIn.disconnect();
  }






  bool updateIsUpdateTernsStatus({bool isUpdate = true, bool? value}){

    if(value != null) {
      _isAgreeTerms = value;

    }else{
      _isAgreeTerms = !_isAgreeTerms;

    }
    if(isUpdate) {
      notifyListeners();

    }

    return _isAgreeTerms;
  }

  void setCountSocialLoginOptions ({int? count, bool isReload = false}){
    if(isReload){
      _countSocialLoginOptions = 0;
    }else{
      _countSocialLoginOptions = count ?? 0;
    }
  }

  void toggleIsNumberLogin ({bool? value, bool isUpdate = true}) {
    if(value == null){
      _isNumberLogin = !_isNumberLogin;
    }else{
      _isNumberLogin = value;
    }

    if(isUpdate){
      notifyListeners();
    }
  }

  String? getGuestId()=> isLoggedIn() ? null : authRepo?.getGuestId();

  Future<void> addOrUpdateGuest() async {
    String? fcmToken = await  authRepo?.getDeviceToken();
    ApiResponseModel apiResponse = await authRepo!.addOrUpdateGuest(fcmToken);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200
        && apiResponse.response?.data != null && apiResponse.response?.data.isNotEmpty &&  apiResponse.response?.data['guest']['id'] != null) {

      print('-------------------(GUEST ID)--------${apiResponse.response?.data['guest']['id'].toString()}');

      authRepo?.saveGuestId('${apiResponse.response?.data['guest']['id'].toString()}');

      print('---------------------(GUEST ID IN SHARED PREF)-----${authRepo?.sharedPreferences?.getString(AppConstants.guestId)}');

    }
  }


}
