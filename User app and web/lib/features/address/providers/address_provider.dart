import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/features/address/domain/reposotories/location_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressProvider with ChangeNotifier {
  final SharedPreferences? sharedPreferences;
  final LocationRepo? locationRepo;

  AddressProvider({required this.sharedPreferences, this.locationRepo});


  GoogleMapController? _mapController;
  List<Prediction> _predictionList = [];
  List<AddressModel>? _addressList;
  bool _isLoading = false;
  String? _errorMessage = '';
  String? _addressStatusMessage = '';
  List<String> _getAllAddressType = [];
  int _selectAddressIndex = 0;
  String? _countryCode;


  final List<Marker> _markers = <Marker>[];
  List<Marker> get markers => _markers;
  GoogleMapController? get mapController => _mapController;
  List<AddressModel>? get addressList => _addressList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get addressStatusMessage => _addressStatusMessage;
  List<String> get getAllAddressType => _getAllAddressType;
  int get selectAddressIndex => _selectAddressIndex;
  String? get countryCode => _countryCode;


  set setAddressStatusMessage(String? message)=> _addressStatusMessage = message;
  set setErrorMessage(String? message)=> _errorMessage = message;





  void deleteUserAddressByID(int? id, int index, Function callback) async {
    ApiResponseModel apiResponse = await locationRepo!.removeAddressByID(id);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressList!.removeAt(index);
      callback(true, 'Deleted address successfully');
      notifyListeners();
    } else {
      callback(false, ApiCheckerHelper.getError(apiResponse).errors![0].message);
    }
  }

  Future<ResponseModel?> initAddressList() async {
    ResponseModel? responseModel;
    ApiResponseModel apiResponse = await locationRepo!.getAllAddress();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressList = [];
      apiResponse.response!.data.forEach((address) => _addressList!.add(AddressModel.fromJson(address)));
      responseModel = ResponseModel(true, 'successful');
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
    return responseModel;
  }



  Future<ResponseModel> addAddress(AddressModel addressModel, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    _errorMessage = '';
    _addressStatusMessage = null;
    ApiResponseModel apiResponse = await locationRepo!.addAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      initAddressList();
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      _addressStatusMessage = message;
    } else {

      _errorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _errorMessage);
    }
    notifyListeners();
    return responseModel;
  }

  // for address update screen
  Future<ResponseModel> updateAddress(BuildContext context, {required AddressModel addressModel, int? addressId}) async {
    _isLoading = true;
    notifyListeners();
    _errorMessage = '';
    _addressStatusMessage = null;
    ApiResponseModel apiResponse = await locationRepo!.updateAddress(addressModel, addressId);
    _isLoading = false;
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      initAddressList();
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      _addressStatusMessage = message;
    } else {
      _errorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _errorMessage);
    }
    notifyListeners();
    return responseModel;
  }


  updateAddressIndex(int index, bool notify) {
    _selectAddressIndex = index;
    if(notify) {
      notifyListeners();
    }
  }

  initializeAllAddressType({BuildContext? context}) {
    if (_getAllAddressType.isEmpty) {
      _getAllAddressType = [];
      _getAllAddressType = locationRepo!.getAllAddressType(context: context);
    }
  }

  Future<List<Prediction>> searchAddress(BuildContext context, String text) async {
    if(text.isNotEmpty) {
      ApiResponseModel response = await locationRepo!.searchLocation(text);
      if (response.response?.statusCode == 200 && response.response!.data['status'] == 'OK') {
        _predictionList = [];
        response.response!.data['predictions'].forEach((prediction) => _predictionList.add(Prediction.fromJson(prediction)));
      } else {
        _predictionList = [];
      }
    }
    return _predictionList;
  }


  int? getAddressIndex(AddressModel address){
    int? index;
    if(_addressList != null) {
      for(int i = 0; i < _addressList!.length; i ++) {
        if(_addressList![i].id == address.id) {
          index = i;
          break;
        }
      }
    }
    return index;
  }

  void setCountryCode (String code, {bool isUpdate = false}){
    if(!code.contains('+')){
      _countryCode = "+$code";
    }else{
      _countryCode = code;
    }
    if(isUpdate){
      notifyListeners();
    }
  }



}
