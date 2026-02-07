import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/data/datasource/local/cache_response.dart';
import 'package:hexacom_user/features/wishlist/domain/models/wishlist_model.dart';
import 'package:hexacom_user/features/wishlist/domain/reposotories/wishlist_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/helper/data_sync_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';

class WishListProvider extends ChangeNotifier {
  final WishListRepo? wishListRepo;

  WishListProvider({required this.wishListRepo});

  List<Product>? _wishList;
  List<Product>? get wishList => _wishList;
  Product? _product;
  Product? get product => _product;
  List<int?> _wishIdList = [];
  List<int?> get wishIdList => _wishIdList;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Product? wishProduct;

  void addToWishList(Product product) async {
    _wishList?.add(product);
    _wishIdList.add(product.id);
    int count = product.wishlistCount ?? 0;
    wishProduct = product.copyWith(count + 1);
    notifyListeners();
    ApiResponseModel apiResponse = await wishListRepo!.addWishList([product.id]);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBar(getTranslated('item_added_to', Get.context! ), Get.context!, isError: false);
    } else {
      _wishList?.remove(product);
      _wishIdList.remove(product.id);
      // wishProduct = product.copyWith(count - 1);
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void removeFromWishList(Product product, BuildContext context) async {
    _wishList!.remove(product);
    _wishIdList.remove(product.id);
    int count = product.wishlistCount ?? 1;
    if(count > 0){
      wishProduct = product.copyWith(count - 1);
    }
    notifyListeners();
    ApiResponseModel apiResponse = await wishListRepo!.removeWishList([product.id]);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBar(getTranslated('item_removed_from', Get.context!), Get.context!, isError: false);
    } else {
      _wishList!.add(product);
      _wishIdList.add(product.id);
      // wishProduct = product.copyWith(count + 1);
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }


  Future<void> getWishList() async {
    _isLoading = true;
    _wishList = [];
    _wishIdList = [];

    DataSyncProvider.fetchAndSyncData(
      fetchFromLocal: ()=> wishListRepo!.getWishList<CacheResponseData>(source: DataSourceEnum.local),
      fetchFromClient: ()=> wishListRepo!.getWishList(source: DataSourceEnum.client),
      onResponse: (data, _){
        _wishList = [];
        _wishList!.addAll(WishListModel.fromJson(data).products!);
        for(int i = 0; i< _wishList!.length; i++){
          _wishIdList.add(_wishList![i].id);
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearWishList(){
    _wishIdList = [];
    _wishList = [];
    notifyListeners();
  }
}
