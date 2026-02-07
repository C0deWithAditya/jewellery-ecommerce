import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/onboarding_model.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/images.dart';

class OnBoardingRepo {
  final DioClient? dioClient;
  OnBoardingRepo({required this.dioClient});

  Future<ApiResponseModel> getOnBoardingList(BuildContext context) async {
    try {
      List<OnBoardingModel> onBoardingList = [
        OnBoardingModel(Images.onBoardingOne, getTranslated('select_product', context), getTranslated('on_boarding_text_1', context)),
        OnBoardingModel(Images.onBoardingTwo, getTranslated('complete_payment', context), getTranslated('on_boarding_text_2', context)),
        OnBoardingModel(Images.onBoardingThree, getTranslated('get_the_order', context), getTranslated('on_boarding_text_3', context)),
      ];

      Response response = Response(requestOptions: RequestOptions(path: ''), data: onBoardingList, statusCode: 200);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
