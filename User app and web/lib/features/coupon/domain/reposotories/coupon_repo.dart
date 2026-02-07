import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/utill/app_constants.dart';

class CouponRepo {
  final DioClient? dioClient;
  CouponRepo({required this.dioClient});

  Future<ApiResponseModel> getCouponList() async {
    try {
      final response = await dioClient!.get(AppConstants.couponUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> applyCoupon(String couponCode) async {
    try {
      final response = await dioClient!.get('${AppConstants.couponApplyUri}$couponCode');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}