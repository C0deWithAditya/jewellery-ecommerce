import 'dart:async';

import 'package:emarket_delivery_boy/features/auth/providers/auth_provider.dart';
import 'package:emarket_delivery_boy/features/auth/screens/login_screen.dart';
import 'package:emarket_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:emarket_delivery_boy/features/maintenance/screens/maintenance_screen.dart';
import 'package:emarket_delivery_boy/helper/maintenance_helper.dart';
import 'package:emarket_delivery_boy/main.dart';
import 'package:flutter/material.dart';
import 'package:emarket_delivery_boy/commons/models/api_response.dart';
import 'package:emarket_delivery_boy/commons/models/config_model.dart';
import 'package:emarket_delivery_boy/features/splash/domain/reposotories/splash_repo.dart';
import 'package:emarket_delivery_boy/helper/api_checker_helper.dart';
import 'package:provider/provider.dart';

class SplashProvider extends ChangeNotifier {
  final SplashRepo splashRepo;
  SplashProvider({required this.splashRepo});

  ConfigModel? _configModel;
  BaseUrls? _baseUrls;

  ConfigModel? get configModel => _configModel;
  BaseUrls? get baseUrls => _baseUrls;

  Future<bool> initConfig(BuildContext context, {bool? fromNotification}) async {
    ApiResponse apiResponse = await splashRepo.getConfig();
    bool isSuccess;
    if (apiResponse.response?.statusCode == 200) {
      _configModel = ConfigModel.fromJson(apiResponse.response?.data);
      _baseUrls = ConfigModel.fromJson(apiResponse.response!.data).baseUrls;
      isSuccess = true;

      if(!MaintenanceHelper.isMaintenanceModeEnable(configModel)){
        if(MaintenanceHelper.isCustomizeMaintenance(configModel)){
          DateTime now = DateTime.now();
          DateTime specifiedDateTime = DateTime.parse(_configModel!.maintenanceMode!.maintenanceTypeAndDuration!.startDate!);

          Duration difference = specifiedDateTime.difference(now);

          if(difference.inMinutes > 0 && (difference.inMinutes < 60 || difference.inMinutes == 60)){
            _startTimer(specifiedDateTime);
          }

        }
      }

      if(fromNotification ?? false){
        if(MaintenanceHelper.isMaintenanceModeEnable(configModel)) {
          Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => const MaintenanceScreen()));
        }else if (!MaintenanceHelper.isMaintenanceModeEnable(configModel)){
          if(Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn()){
            Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => const DashboardScreen()));
          }else{
            Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }
        }
      }
      notifyListeners();
    } else {
      isSuccess = false;
      ApiCheckerHelper.checkApi(apiResponse);
    }
    return isSuccess;
  }

  void _startTimer (DateTime startTime){
    Timer.periodic(const Duration(seconds: 30), (Timer timer){
      DateTime now = DateTime.now();
      if (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) {
        timer.cancel();
        Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    });
  }

  Future<bool> initSharedData()=> splashRepo.initSharedData();

  Future<bool> removeSharedData()=> splashRepo.removeSharedData();


}