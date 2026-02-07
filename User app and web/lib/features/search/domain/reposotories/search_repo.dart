
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  SearchRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getSearchProductList({
    required int offset,
    String? query,
    List<int>? categoryIds,
    int? rating,
    double? priceLow,
    double? priceHigh,
    String? shortBy,
  }) async {

    String url = '${AppConstants.searchUri}?limit=10&offset=$offset';

    if(query != null) {
      url = '$url&name=$query';

    }

    if(rating != null) {
      url = '$url&rating=$rating';
    }

    if(priceLow != null && priceHigh != null){
      url = '$url&price_low=$priceLow&price_high=$priceHigh';
    }

    if(categoryIds != null && categoryIds.isNotEmpty) {
      url = '$url&category_id=$categoryIds';
    }
    if(shortBy != null) {
      url = '$url&sort_by=$shortBy';
    }

    try {
      final response = await dioClient!.get(url);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // for save home address
  Future<void> saveSearchAddress(String searchAddress) async {
    try {
      List<String> searchKeywordList = sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
      if (!searchKeywordList.contains(searchAddress)) {
        searchKeywordList.add(searchAddress);
      }
      await sharedPreferences!.setStringList(AppConstants.searchAddress, searchKeywordList);
    } catch (e) {
      rethrow;
    }
  }

  List<String> getSearchAddress() {
    return sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
  }

  Future<bool> clearSearchAddress() async {
    return sharedPreferences!.setStringList(AppConstants.searchAddress, []);
  }
}
