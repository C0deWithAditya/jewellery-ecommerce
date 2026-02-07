import 'package:hexacom_user/utill/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/onboarding_model.dart';
import 'package:hexacom_user/features/onboarding/domain/reposotories/onboarding_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingProvider with ChangeNotifier {
  final OnBoardingRepo? onboardingRepo;
  final SharedPreferences? sharedPreferences;

  OnBoardingProvider({required this.onboardingRepo, required this.sharedPreferences}) {
    _loadShowOnBoardingStatus();
  }
  final List<OnBoardingModel> _onBoardingList = [];

  List<OnBoardingModel> get onBoardingList => _onBoardingList;

  int _selectedIndex = 0;
  bool _showOnBoardingStatus = false;
  int get selectedIndex => _selectedIndex;
  bool get showOnBoardingStatus => _showOnBoardingStatus;

  changeSelectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
  void _loadShowOnBoardingStatus() async {
    _showOnBoardingStatus = sharedPreferences!.getBool(AppConstants.onBoardingSkip) ?? false;
  }
  void toggleShowOnBoardingStatus() {
    sharedPreferences!.setBool(AppConstants.onBoardingSkip, true);
  }

  void initBoardingList(BuildContext context) async {
    ApiResponseModel apiResponse = await onboardingRepo!.getOnBoardingList(context);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _onBoardingList.clear();
      _onBoardingList.addAll(apiResponse.response!.data);

    }
    notifyListeners();
  }
}
