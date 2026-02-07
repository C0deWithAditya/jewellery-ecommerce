import 'package:dio/dio.dart';
import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/product_details_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/common/reposotories/product_repo.dart';
import 'package:hexacom_user/features/product/domain/models/new_arrival_products_model.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/data_sync_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepo? productRepo;
  ProductProvider({required this.productRepo});

  // Latest products
  Product? _product;
  ProductModel? _latestProductModel;
  List<Product>? _offerProductList;
  bool _isLoading = false;
  List<int>? _variationIndex;
  int? _quantity = 1;
  int _imageSliderIndex = 0;
  int _tabIndex = 0;
  int offset = 1;
  ProductDetailsModel? _productDetailsModel;


  Product? get product => _product;
  ProductModel? get latestProductModel => _latestProductModel;
  List<Product>? get offerProductList => _offerProductList;
  bool get isLoading => _isLoading;
  List<int>? get variationIndex => _variationIndex;
  int? get quantity => _quantity;
  int get imageSliderIndex => _imageSliderIndex;
  int get tabIndex => _tabIndex;
  ProductDetailsModel? get productDetailsModel => _productDetailsModel;


  NewArrivalProductsModel? _newArrivalProductsModel;
  NewArrivalProductsModel? get newArrivalProductsModel => _newArrivalProductsModel;

  void getLatestProductList(int offset, {ProductFilterType? filterType, bool isUpdate = true, int? limit = 15}) async {
    if(offset == 1) {
      _latestProductModel = null;

      if(isUpdate) {
        notifyListeners();
      }

    }
    
    if(offset == 1) {
      DataSyncProvider.fetchAndSyncData(
        fetchFromLocal: ()=> productRepo!.getLatestProductList(offset, limit ?? 15, filterType, source: DataSourceEnum.local),
        fetchFromClient: ()=> productRepo!.getLatestProductList(offset, limit ?? 15, filterType, source: DataSourceEnum.client),
        onResponse: (data, _){
          _latestProductModel = ProductModel.fromJson(data);
          
          notifyListeners();
        },
      );
    }else {
      ApiResponseModel apiResponse = await productRepo!.getLatestProductList<Response>(offset, limit ?? 15, filterType, source: DataSourceEnum.client);

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

        if(offset == 1){
          _latestProductModel = ProductModel.fromJson(apiResponse.response?.data);
        } else {
          _latestProductModel!.totalSize = ProductModel.fromJson(apiResponse.response?.data).totalSize;
          _latestProductModel!.offset = ProductModel.fromJson(apiResponse.response?.data).offset;
          _latestProductModel!.products!.addAll(ProductModel.fromJson(apiResponse.response?.data).products!);
        }

        _isLoading = false;
        notifyListeners();
      } else {
        showCustomSnackBar(ApiCheckerHelper.getError(apiResponse).errors?.first.message, Get.context!);
      }
    }
    
   
  }

  Future<void> getProductDetails(Product product, CartModel? cart) async {
    if(product.name != null) {
      _product = product;
    }else {
      _product = null;
      ApiResponseModel apiResponse = await productRepo!.getProductDetails(product.id.toString());
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _productDetailsModel = ProductDetailsModel.fromJson(apiResponse.response!.data);
        _product = _productDetailsModel?.product;
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }
    initDataLoad(_productDetailsModel?.product, cart);
  }

  Future<void> getOfferProductList(bool reload) async {
    if(offerProductList == null || reload) {
      DataSyncProvider.fetchAndSyncData(
        fetchFromLocal: ()=> productRepo!.getOfferProductList(source: DataSourceEnum.local),
        fetchFromClient: ()=> productRepo!.getOfferProductList(source: DataSourceEnum.client),
        onResponse: (data, _){
          _offerProductList = [];
          data.forEach((offerProduct) => _offerProductList!.add(Product.fromJson(offerProduct)));
          
          notifyListeners();
        },
      );
    }
  }


  Future<void> getNewArrivalProducts(int offset, bool reload) async {
    if(reload) {
      _newArrivalProductsModel = null;
      notifyListeners();
    }
    
    if(offset == 1) {
      DataSyncProvider.fetchAndSyncData(
        fetchFromLocal: ()=> productRepo!.getNewArrivalProducts(offset, source: DataSourceEnum.local),
        fetchFromClient: ()=> productRepo!.getNewArrivalProducts(offset, source: DataSourceEnum.client),
        onResponse: (data, _){
          _newArrivalProductsModel = NewArrivalProductsModel.fromJson(data);
          notifyListeners();
        },
      );
      
    }else {
      ApiResponseModel? response = await productRepo!.getNewArrivalProducts(offset, source: DataSourceEnum.client);
      if (response.response != null && response.response?.data != null && response.response?.statusCode == 200) {
        if(offset == 1){
          _newArrivalProductsModel = NewArrivalProductsModel.fromJson(response.response?.data);
        } else {
          _newArrivalProductsModel!.totalSize = NewArrivalProductsModel.fromJson(response.response?.data).totalSize;
          _newArrivalProductsModel!.offset = NewArrivalProductsModel.fromJson(response.response?.data).offset;
          _newArrivalProductsModel!.products!.addAll(NewArrivalProductsModel.fromJson(response.response?.data).products!);
        }
        notifyListeners();

      } else {
        ApiCheckerHelper.checkApi(response);
      }
      
    }

  }


  void showBottomLoader() {
    _isLoading = true;
    notifyListeners();
  }

  void setImageSliderIndex(int index) {
    _imageSliderIndex = index;
    notifyListeners();
  }

  void initDataLoad(Product? product, CartModel? cart, {bool isUpdate = true}) {
    _tabIndex = 0;
    _variationIndex = [];
    if(cart != null) {
      _quantity = cart.quantity;
      List<String> variationTypes = [];
      if(cart.variation!.isNotEmpty &&  cart.variation![0].type != null) {
        variationTypes.addAll(cart.variation![0].type!.split('-'));
      }
      int varIndex = 0;
      for (var choiceOption in product!.choiceOptions!) {
        for (int index = 0; index < choiceOption.options!.length; index++) {
          if (choiceOption.options![index].trim().replaceAll(' ', '') ==
              variationTypes[varIndex].trim()) {
            _variationIndex!.add(index);
            break;
          }
        }
        varIndex++;
      }
    }else {
      _quantity = 1;
      product?.choiceOptions?.forEach((element) => _variationIndex?.add(0));

    }
    //todo check listener
    if(isUpdate) {
      notifyListeners();
    }
  }

  void setProductQuantity(bool isIncrement, int? stock, BuildContext context) {
    if (isIncrement) {
      if(_quantity! >= stock!) {
        showCustomSnackBar(getTranslated('out_of_stock', context), context);
      }else {
        _quantity = _quantity! + 1;
      }
    } else {
      _quantity = _quantity! - 1;
    }
    notifyListeners();
  }

  void setCartVariationIndex(int index, int i) {
    _variationIndex![index] = i;
    _quantity = 1;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }


}
