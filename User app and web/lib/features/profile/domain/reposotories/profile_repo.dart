import 'dart:io';
import 'dart:typed_data';
import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/reposotories/data_sync_repo.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/userinfo_model.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepo extends DataSyncRepo{
  ProfileRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel> getAddressTypeList() async {
    try {
      List<String> addressTypeList = [
        'Select Address type',
        'Home',
        'Office',
        'Other',
      ];
      Response response = Response(requestOptions: RequestOptions(path: ''), data: addressTypeList, statusCode: 200);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel<T>> getUserInfo<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.customerInfoUri, source);

  }

  Future<http.StreamedResponse> updateProfile(UserInfoModel userInfoModel, String password, XFile?  file, String token) async {
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}${AppConstants.updateProfileUri}'));
    request.headers.addAll(<String,String>{'Authorization': 'Bearer $token'});
    if(file != null && ResponsiveHelper.isMobilePhone()) {
      File file0 = File(file.path);
      request.files.add(http.MultipartFile('image', file0.readAsBytes().asStream(), file0.lengthSync(), filename: file0.path.split('/').last));
    }else if(file != null && ResponsiveHelper.isWeb()) {
      Uint8List list = await file.readAsBytes();
      request.files.add(http.MultipartFile('image', file.readAsBytes().asStream(), list.length, filename: file.path));
    }
    Map<String, String> fields = {};
    if(password.isEmpty) {
      fields.addAll(<String, String>{
        '_method': 'put', 'f_name': userInfoModel.fName!, 'l_name': userInfoModel.lName!, 'phone': userInfoModel.phone!, 'email': userInfoModel.email ?? ''
      });
    }else {
      fields.addAll(<String, String>{
        '_method': 'put', 'f_name': userInfoModel.fName!, 'l_name': userInfoModel.lName!, 'email': userInfoModel.email ?? '', 'phone': userInfoModel.phone!, 'password': password
      });
    }
    request.fields.addAll(fields);
    http.StreamedResponse response = await request.send();
    return response;
  }

  String getUserId() {
    return sharedPreferences!.getString(AppConstants.userId) ?? "";
  }

  Future<void> saveUserID(String userId) async {
    try {
      await sharedPreferences!.setString(AppConstants.userId, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearUserId()async{
    if(sharedPreferences!.containsKey(AppConstants.userId)) {
      await sharedPreferences!.remove(AppConstants.userId);
    }
  }


}