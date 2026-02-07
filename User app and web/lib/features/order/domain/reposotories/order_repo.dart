import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/place_order_model.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  OrderRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getOrderList() async {
    try {
      final response = await dioClient!.get(AppConstants.orderListUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getOrderDetails(String orderID, String? phoneNumber) async {

    if (kDebugMode) {
      print("Order Id: $orderID");
      print("Phone number ===> $phoneNumber");
    }

    try {
      final response = await dioClient!.post(AppConstants.orderDetailsUri, data: {
        'order_id' : orderID, 'phone' : phoneNumber == 'null' ? null : phoneNumber,
      });
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> cancelOrder(String orderID) async {
    try {
      Map<String, dynamic> data = <String, dynamic>{};
      data['order_id'] = orderID;
      data['_method'] = 'put';
      final response = await dioClient!.post(AppConstants.orderCancelUri, data: data);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> trackOrder(String? orderID, String? phoneNumber) async {
    if (kDebugMode) {
      print("Order Id: $orderID");
      print("Phone number: $phoneNumber");
    }
    try {
      final response = await dioClient!.post(AppConstants.trackUri, data: {
        "order_id" : orderID,
        "phone": (phoneNumber != "null" && phoneNumber != null ) ? phoneNumber : ""
      });

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> placeOrder(PlaceOrderModel orderBody) async {
    try {
      final response = await dioClient!.post(AppConstants.placeOrderUri, data: orderBody.toJson());
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getDeliveryManData(String? orderID) async {
    try {
      final response = await dioClient!.get('${AppConstants.lastLocationUri}$orderID');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    try {
      Response response = await dioClient!.get('${AppConstants.distanceMatrixUri}'
          '?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
          '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
  Future<void> setPlaceOrder(String placeOrder)async{
    await sharedPreferences!.setString(AppConstants.placeOrderData, placeOrder);
  }
  String? getPlaceOrder(){
    return sharedPreferences!.getString(AppConstants.placeOrderData);
  }
  Future<void> clearPlaceOrder()async{
    await sharedPreferences!.remove(AppConstants.placeOrderData);
  }

  Future<ApiResponseModel> getReorderData(String orderID) async {
    try {
      final response = await dioClient!.get('${AppConstants.reorderProductList}?order_id=$orderID');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }


}