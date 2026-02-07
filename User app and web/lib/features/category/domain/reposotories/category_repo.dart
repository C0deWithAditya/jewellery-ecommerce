import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/reposotories/data_sync_repo.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/utill/app_constants.dart';

class CategoryRepo extends DataSyncRepo{
  CategoryRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getCategoryList<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.categoryUri, source);

  }

  Future<ApiResponseModel> getSubCategoryList(String parentID) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.subCategoryUri}$parentID',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getCategoryProductList(String categoryID) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.categoryProductUri}$categoryID',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
  Future<ApiResponseModel<T>> getFeatureCategories<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.featureCategory, source);

  }

}