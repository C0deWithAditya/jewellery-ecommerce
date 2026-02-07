import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/features/address/domain/reposotories/location_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final LocationRepo locationRepo;

  LocationProvider({required this.sharedPreferences, required this.locationRepo});


  bool _isLoading = false;
  Position _currentPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
  Position _pickPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
  String? _address;
  String? _pickAddress = '';
  bool _willUpdatePosition = true;
  bool _changeAddress = true;
  String? _pickedAddressLatitude;
  String? _pickedAddressLongitude;


  bool get isLoading => _isLoading;
  Position get currentPosition => _currentPosition;
  Position get pickPosition => _pickPosition;
  String? get address => _address;
  String? get pickAddress => _pickAddress;
  List<AddressModel>? _addressList;
  String? get pickedAddressLatitude => _pickedAddressLatitude;
  String? get pickedAddressLongitude => _pickedAddressLongitude;


  set setAddress(String? addressValue)=> _address = addressValue;

  void getCurrentLocation(BuildContext context, bool fromAddress, {GoogleMapController? mapController}) async {
    Position position;

    _isLoading = true;
    notifyListeners();

    try {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    }catch(e) {
      position = Position(
        latitude: 0, longitude: 0, timestamp: DateTime.now(), accuracy: 1,
        altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
        altitudeAccuracy: 1, headingAccuracy: 1,
      );
    }

    if(fromAddress) {
      _currentPosition = position;
    }else {
      _pickPosition = position;
    }

    if(mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16),
      ));
    }

    if(fromAddress) {
      _address = await getAddressFromGeocode(LatLng(position.latitude, position.longitude));
    }
    _isLoading = false;
    notifyListeners();
  }

  void setPickedAddressLatLon(String? lat, String? lon, {bool isUpdate = true}){
    _pickedAddressLatitude = lat;
    _pickedAddressLongitude = lon;
    if(isUpdate){
      notifyListeners();
    }
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    String? address;

    ApiResponseModel? response = await locationRepo.getAddressFromGeocode(latLng);
    if(response.response?.statusCode == 200 && response.response?.data['status'] == 'OK') {
      address = response.response?.data['results'][0]['formatted_address'].toString();

    }else {
      ApiCheckerHelper.checkApi(response);
    }

    return address ?? getTranslated('unknown_location_found', Get.context!);
  }

  void updatePosition(CameraPosition? cameraPosition, bool fromAddress, String? address, bool forceNotify) async {
    if(_willUpdatePosition || forceNotify) {
      _isLoading = true;
      notifyListeners();
      try {
        Position position = Position(
          latitude: double.parse(cameraPosition!.target.latitude.toStringAsFixed(7)), longitude: double.parse(cameraPosition.target.longitude.toStringAsFixed(7)), timestamp: DateTime.now(),
          heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1, altitudeAccuracy: 1, headingAccuracy: 1,
        );

        if (fromAddress) {
          _currentPosition = position;
          print("-------(HERE IT IS)--------- ${_currentPosition.toJson().toString()}");
        } else {

          _pickPosition = position;

          print("-------(HERE IT IS ELSE)--------- ${_pickPosition.toJson().toString()}");
        }

        if (_changeAddress) {
          String addressFromGeocode = await getAddressFromGeocode(LatLng(cameraPosition.target.latitude, cameraPosition.target.longitude));
          if(fromAddress) {
            _address = addressFromGeocode;
            print("-----(ADDRESS IN FROM ADDRESS)--------- ${_address.toString()}");

          }else{
            _pickAddress = addressFromGeocode;
            print("-----(ADDRESS IN FROM PICK ADDRESS)--------- ${_pickAddress.toString()}");

          }
        } else {
          _changeAddress = true;
        }
      } catch (e) {
        debugPrint('error ==> $e');
      }
      _isLoading = false;
      notifyListeners();

    }else {
      _willUpdatePosition = true;
    }
  }

  void setLocationData(bool isUpdate) {
    _currentPosition = _pickPosition;
    _address = _pickAddress;
    _willUpdatePosition = false;
    if(isUpdate){
      notifyListeners();
    }
  }

  void setPickData() {
    _pickPosition = _currentPosition;
    _pickAddress = _address;
  }

  void setLocation(String? placeID, String? address, GoogleMapController? mapController) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel response = await locationRepo.getPlaceDetails(placeID);

    PlacesDetailsResponse detail = PlacesDetailsResponse.fromJson(response.response?.data);

    print('------------(SET LOCATION)------------${detail.result.geometry?.toJson().toString()}');

    _pickPosition = Position(
      longitude: detail.result.geometry!.location.lng, latitude: detail.result.geometry!.location.lat,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
    );

    print('---------------------(API LOCATION)------${detail.result.geometry!.location.lat} and ${detail.result.geometry!.location.lng}');

    print('------------(SET LOCATION 2)------------${_pickPosition.toJson().toString()}');
    print('------------(SET LOCATION 3)------------$address');
    print('------------(SET LOCATION 4)------------$_pickAddress');

    _pickAddress = address;
    _address = address;
    _changeAddress = false;


    if(mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
        detail.result.geometry!.location.lat, detail.result.geometry!.location.lng,
      ), zoom: 16)));
    }


    _isLoading = false;
    notifyListeners();
  }

  Future<ResponseModel?> initAddressList() async {
    ResponseModel? responseModel;
    _addressList = null;
    ApiResponseModel apiResponse = await locationRepo.getAllAddress();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressList = [];
      apiResponse.response!.data.forEach((address) => _addressList!.add(AddressModel.fromJson(address)));
      responseModel = ResponseModel(true, 'successful');
    } else {
      _addressList = [];
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
    return responseModel;
  }











}
