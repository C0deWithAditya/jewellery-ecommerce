import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/features/search/domain/reposotories/search_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';


class SearchProvider with ChangeNotifier {
  final SearchRepo? searchRepo;

  SearchProvider({required this.searchRepo});

  double? _lowerValue;
  double? _upperValue;
  List<String> _historyList = [];
  bool _isSearch = true;
  List<int> _selectCategoryList = [];
  SearchShortBy? _selectedSearchShotBy;
  TextEditingController _searchController = TextEditingController();
  ProductModel? _searchProductModel;
  int _rating = -1;

  double? get lowerValue => _lowerValue;
  double? get upperValue => _upperValue;
  bool get isSearch => _isSearch;
  List<int> get selectCategoryList => _selectCategoryList;
  List<String> get historyList => _historyList;
  TextEditingController  get searchController=> _searchController;
  SearchShortBy? get selectedSearchShotBy => _selectedSearchShotBy;
  int get rating => _rating;



  void getSearchText(String searchText){
    _searchController = TextEditingController(text: searchText);
    notifyListeners();
  }

  void changeSearchStatus(){
    _isSearch = !_isSearch;
    notifyListeners();
  }


  void setLowerAndUpperValue(double? lower, double? upper, {bool isUpdate = true}) {
    _lowerValue = lower;
    _upperValue = upper;

    if(isUpdate) {
      notifyListeners();
    }
  }


  ProductModel? get searchProductModel => _searchProductModel;




  Future<void> searchProduct({
    required int offset,
    required String query,
    List<int>? categoryIds,
    int? rating,
    double? priceLow,
    double? priceHigh,
    SearchShortBy? shortBy,
    bool isUpdate = false,
  }) async {

    if(offset == 1) {
      _searchProductModel = null;
      _upperValue = 0;
      _lowerValue = 0;

      if(isUpdate) {
        notifyListeners();
      }

    }

    ApiResponseModel apiResponse = await searchRepo!.getSearchProductList(
      offset: offset,
      query: query, categoryIds: categoryIds,
      priceHigh: priceHigh, priceLow: priceLow, rating: rating,
      shortBy: getShortByValue(shortBy),
    );
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      if(offset == 1){
        _searchProductModel = ProductModel.fromJson(apiResponse.response?.data);
      } else {
        _searchProductModel!.totalSize = ProductModel.fromJson(apiResponse.response?.data).totalSize;
        _searchProductModel!.offset = ProductModel.fromJson(apiResponse.response?.data).offset;
        _searchProductModel!.products!.addAll(ProductModel.fromJson(apiResponse.response?.data).products!);
      }


    } else {
      _searchProductModel = ProductModel(products: []);
      ApiCheckerHelper.checkApi(apiResponse);
    }

    notifyListeners();
  }

  void getHistoryList() {
    _historyList = [];
    _historyList.addAll(searchRepo!.getSearchAddress());
  }

  void saveSearchAddress(String searchAddress) async {
    if (!_historyList.contains(searchAddress)) {
      _historyList.add(searchAddress);
      searchRepo!.saveSearchAddress(searchAddress);
      notifyListeners();
    }
  }

  void clearSearchAddress() async {
    searchRepo!.clearSearchAddress();
    _historyList = [];
    notifyListeners();
  }


  void setRating(int rate, {bool isUpdate = true}) {
    _rating = rate;

    if(isUpdate) {
      notifyListeners();
    }

  }

 void selectCategoryListAdd(int index, {bool isClear = false, bool isUpdate = true}) {
    if(isClear) {
      _selectCategoryList = [];
    }else{
      if(_selectCategoryList.contains(index)) {
        _selectCategoryList.remove(index);
      }else {
        _selectCategoryList.add(index);
      }
    }

    if(isUpdate) {
      notifyListeners();
    }
  }

  void resetSearchFilterData({bool isUpdate = false}) {
    setRating(-1, isUpdate: isUpdate);
    selectCategoryListAdd(-1, isClear: true, isUpdate: isUpdate);
    setLowerAndUpperValue(null, null, isUpdate: isUpdate);

  }

  void setSelectShortBy(SearchShortBy? shortBy, {bool isUpdate = true}) {
    _selectedSearchShotBy = shortBy;
    if(isUpdate) {
      notifyListeners();
    }

  }

  String? getShortByValue(SearchShortBy? shortBy) {
    String? value;
    switch(shortBy) {
      case SearchShortBy.newArrivals:
        value = 'new_arrival';
        break;
      case SearchShortBy.offerProducts:
        value = 'offer_product';
        break;
      case null:
        break;
    }

    return value;
  }




}
