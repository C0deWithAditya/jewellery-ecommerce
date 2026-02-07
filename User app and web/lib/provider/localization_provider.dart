import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/features/home/screens/home_screen.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  DioClient? dioClient;
  final SharedPreferences? sharedPreferences;

  LocalizationProvider({required this.sharedPreferences, required this.dioClient}) {
    _loadCurrentLanguage();
  }

  Locale _locale = Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode);
  bool _isLtr = true;
  Locale get locale => _locale;
  bool get isLtr => _isLtr;

  Future<void> setLanguage(Locale locale) async {
    _locale = locale;
    if(_locale.languageCode == 'ar') {
      _isLtr = false;
    }else {
      _isLtr = true;
    }
    _saveLanguage(_locale);
    await dioClient!.updateHeader(getToken: sharedPreferences!.getString(AppConstants.token)).then((value){
    HomeScreen.loadData(Get.context!, true);
    });
    notifyListeners();
  }

  void _loadCurrentLanguage() async {
    _locale = Locale(sharedPreferences!.getString(AppConstants.languageCode) ?? AppConstants.languages[0].languageCode!,
        sharedPreferences!.getString(AppConstants.countryCode) ?? AppConstants.languages[0].countryCode);
    _isLtr = _locale.languageCode != 'ar';
    notifyListeners();
  }

  _saveLanguage(Locale locale) async {
    sharedPreferences!.setString(AppConstants.languageCode, locale.languageCode);
    sharedPreferences!.setString(AppConstants.countryCode, locale.countryCode!);
  }
}