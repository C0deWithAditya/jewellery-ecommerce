import 'dart:async';
import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:hexacom_user/common/reposotories/product_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/helper/data_sync_provider.dart';
import 'package:hexacom_user/helper/date_converter_helper.dart';
import 'package:flutter/cupertino.dart';

class FlashSaleProvider extends ChangeNotifier {
  final ProductRepo productRepo;
  FlashSaleProvider({required this.productRepo});


  FlashSaleModel? _flashSaleModel;
  Duration? _duration;
  Timer? _timer;
  int _pageIndex = 1;

  Duration? get duration => _duration;
  FlashSaleModel? get flashSaleModel => _flashSaleModel;
  int get pageIndex => _pageIndex;

  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  set setFlashSaleModel(FlashSaleModel? value)=> _flashSaleModel = value;


  Future<void> getFlashSaleProducts(int offset, bool reload, {ProductFilterType? filterType}) async {
    if(reload) {
      _flashSaleModel = null;
      notifyListeners();
    }

    if(offset == 1) {
      DataSyncProvider.fetchAndSyncData(
        fetchFromLocal: ()=> productRepo.getFlashSale(offset, filterType, source: DataSourceEnum.local),
        fetchFromClient: ()=> productRepo.getFlashSale(offset, filterType, source: DataSourceEnum.client),
        onResponse: (data, _){
          _flashSaleModel = FlashSaleModel.fromJson(data);
          _onInitFlashDealTime();
          notifyListeners();
        },
      );

    }else {

      ApiResponseModel? response = await productRepo.getFlashSale(offset, filterType, source: DataSourceEnum.client);
      if (response.response != null && response.response?.data != null && response.response?.statusCode == 200) {
        if(offset == 1){
          _flashSaleModel = FlashSaleModel.fromJson(response.response?.data);
        } else {
          _flashSaleModel!.totalSize = FlashSaleModel.fromJson(response.response?.data).totalSize;
          _flashSaleModel!.offset = FlashSaleModel.fromJson(response.response?.data).offset;
          _flashSaleModel!.flashSale = FlashSaleModel.fromJson(response.response?.data).flashSale;
          _flashSaleModel!.products!.addAll(FlashSaleModel.fromJson(response.response?.data).products!);
        }

        _onInitFlashDealTime();
        notifyListeners();

      } else {
        ApiCheckerHelper.checkApi(response);
      }

    }
  }

  void _onInitFlashDealTime() {
     if(_flashSaleModel != null && _flashSaleModel?.flashSale != null &&  _flashSaleModel!.flashSale!.endDate != null) {
      DateTime endTime = DateConverterHelper.isoStringToLocalDate(_flashSaleModel!.flashSale!.endDate!);
      _duration = endTime.difference(DateTime.now());
      _timer?.cancel();
      _timer = null;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _duration = _duration! - const Duration(seconds: 1);
        notifyListeners();
      });
    }
  }
}