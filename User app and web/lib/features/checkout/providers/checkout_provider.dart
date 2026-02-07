
import 'dart:async';

import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/check_out_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/features/order/domain/models/distance_model.dart';
import 'package:hexacom_user/features/order/domain/reposotories/order_repo.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class CheckoutProvider extends ChangeNotifier {
  final OrderRepo orderRepo;
  CheckoutProvider({required this.orderRepo});

  int? _paymentMethodIndex;
  ResponseModel? _responseModel;
  int _orderAddressIndex = -1;
  String? _orderType = 'delivery';
  int _branchIndex = 0;
  double _distance = -1;
  CheckOutModel? _checkOutData;
  PaymentMethod? _paymentMethod;
  PaymentMethod? _selectedPaymentMethod;





  int? get paymentMethodIndex => _paymentMethodIndex;
  ResponseModel? get responseModel => _responseModel;
  int get orderAddressIndex => _orderAddressIndex;
  String? get orderType => _orderType;
  int get branchIndex => _branchIndex;
  double get distance => _distance;
  CheckOutModel? get getCheckOutData => _checkOutData;
  PaymentMethod? get paymentMethod => _paymentMethod;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;


  set setCheckOutData(CheckOutModel value) {
    _checkOutData = value;
  }


  void setOrderAddressIndex(int index, {bool notify = true}) {
    _orderAddressIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  void clearPrevData() {
    _orderAddressIndex = -1;
    _branchIndex = 0;
    _paymentMethodIndex = 0;
    _distance = -1;
    _paymentMethod = null;
    _selectedPaymentMethod = null;
  }


  void setOrderType(String? type, {bool notify = true}) {
    _orderType = type;
    if(notify) {
      notifyListeners();
    }
  }

  void setBranchIndex(int index) {
    _branchIndex = index;
    _orderAddressIndex = -1;
    _distance = -1;
    notifyListeners();
  }

  Future<bool> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    _distance = -1;
    bool isSuccess = false;
    ApiResponseModel response = await orderRepo.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.response!.statusCode == 200 && response.response!.data['status'] == 'OK') {
        isSuccess = true;
        _distance = DistanceModel.fromJson(response.response!.data).rows![0].elements![0].distance!.value! / 1000;
      } else {
        _distance = Geolocator.distanceBetween(
          originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
        ) / 1000;
      }
    } catch (e) {
      _distance = Geolocator.distanceBetween(
        originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
      ) / 1000;
    }
    notifyListeners();
    return isSuccess;
  }




  void setPaymentIndex(int? index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    _paymentMethod = null;
    if(isUpdate){
      notifyListeners();
    }
  }

  void savePaymentMethod({int? index, PaymentMethod? method, bool isUpdate = true}){
    if(method != null){
      _selectedPaymentMethod = method.copyWith('online');
    }else if(index != null && index == 0){
      _selectedPaymentMethod = PaymentMethod(
        getWayTitle: getTranslated('cash_on_delivery', Get.context!),
        getWay: 'cash_on_delivery',
        type: 'cash_on_delivery',
      );
    }else{
      _selectedPaymentMethod = null;
    }

    if(isUpdate){
      notifyListeners();
    }

  }

  void changePaymentMethod({PaymentMethod? digitalMethod, bool isUpdate = true, bool isClear = false}){
    if(digitalMethod != null){
      _paymentMethod = digitalMethod;
      _paymentMethodIndex = null;
    }
    if(isClear){
      _paymentMethod = null;
      _selectedPaymentMethod = null;

    }
    if(isUpdate){
      notifyListeners();
    }
  }



}