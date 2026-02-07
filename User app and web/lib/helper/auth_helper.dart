import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:provider/provider.dart';

class AuthHelper{

  static bool isOtpOrSocialLoginEnable (ConfigModel? configModel){
    return ( isOtpLoginEnable (configModel) || ( isSocialMediaLoginEnable (configModel) && (isFacebookLoginEnable(configModel) || isGoogleLoginEnable(configModel)) ) );
  }

  static bool isCustomerVerificationEnable (ConfigModel? configModel) => configModel?.customerVerification?.status ?? false;

  static bool isPhoneVerificationEnable (ConfigModel? configModel) => configModel?.customerVerification?.phone ?? false;

  static bool isEmailVerificationEnable (ConfigModel? configModel) => configModel?.customerVerification?.email ?? false;

  static bool isFirebaseVerificationEnable (ConfigModel? configModel) => configModel?.customerVerification?.firebase ?? false;

  static bool isOtpLoginEnable (ConfigModel? configModel) => configModel?.customerLogin?.loginOption?.otpLogin == 1;

  static bool isManualLoginEnable (ConfigModel? configModel) => configModel?.customerLogin?.loginOption?.manualLogin == 1;

  static bool isSocialMediaLoginEnable (ConfigModel? configModel) => configModel?.customerLogin?.loginOption?.socialMediaLogin == 1;

  static bool isFacebookLoginEnable (ConfigModel? configModel) => configModel?.customerLogin?.socialMediaLoginOptions?.facebook ?? false;

  static bool isGoogleLoginEnable (ConfigModel? configModel) => configModel?.customerLogin?.socialMediaLoginOptions?.google ?? false;

  static bool isAppleLoginEnable (ConfigModel? configModel) => (configModel?.customerLogin?.socialMediaLoginOptions?.apple ?? false) && defaultTargetPlatform == TargetPlatform.iOS;

  static int countSocialLoginOptions (ConfigModel? configModel){
    int count = 0;

    if(isFacebookLoginEnable(configModel)) {
      count++;
    }

    if(isGoogleLoginEnable(configModel)) {
      count++;
    }

    if(isAppleLoginEnable(configModel)) {
      count++;
    }
    return count;
  }

  static void identifyEmailOrNumber(String text, BuildContext context){
    final AuthProvider authProvider = context.read<AuthProvider>();
    if(text.isEmpty && authProvider.isNumberLogin){
      authProvider.toggleIsNumberLogin();
    }
    if(text.startsWith(PhoneNumberCheckerHelper.phoneNumberExp) && !authProvider.isNumberLogin){
      authProvider.toggleIsNumberLogin();
    }
    if(text.contains(PhoneNumberCheckerHelper.wordsAndSpecialCharacters) && authProvider.isNumberLogin){
      authProvider.toggleIsNumberLogin();
    }
  }

}