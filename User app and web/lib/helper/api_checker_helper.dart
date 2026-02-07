import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/error_response_model.dart';
import 'package:hexacom_user/main.dart';

import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:provider/provider.dart';


class ApiCheckerHelper {
  static void checkApi(ApiResponseModel apiResponse) {
    ErrorResponseModel error = getError(apiResponse);
//config-missing
    if( error.errors![0].code == '401' || error.errors![0].code == 'auth-001'
        && ModalRoute.of(Get.context!)?.settings.name != RouteHelper.getLoginRoute(Get.context!)) {
      Provider.of<SplashProvider>(Get.context!, listen: false).removeSharedData();

      if( ModalRoute.of(Get.context!)!.settings.name != RouteHelper.getLoginRoute(Get.context!)) {
        Navigator.pushNamedAndRemoveUntil(Get.context!, RouteHelper.getLoginRoute(Get.context!), (route) => false);
      }
    }else {
      showCustomSnackBar(error.errors![0].message, Get.context!);
    }
  }

  static ErrorResponseModel getError(ApiResponseModel apiResponse){
    ErrorResponseModel error;

    try{
      error = ErrorResponseModel.fromJson(apiResponse);
    }catch(e){
      if(apiResponse.error is String){
        error = ErrorResponseModel(errors: [Errors(code: '', message: apiResponse.error.toString())]);

      }else{
        error = ErrorResponseModel.fromJson(apiResponse.error);
      }
    }
    return error;
  }
}