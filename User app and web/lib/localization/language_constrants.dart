import 'package:hexacom_user/localization/app_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

String getTranslated(String? key, BuildContext context) {
  String? text = key;
  try{
    text = AppLocalization.of(context)!.translate(key);
  }catch (error){
    if (kDebugMode) {
      print('not localized --- $error');
    }
  }
  return text ?? '';
}