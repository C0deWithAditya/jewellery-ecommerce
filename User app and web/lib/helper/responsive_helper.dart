import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {

  static bool isMobilePhone() {
    if (!kIsWeb) {
      return true;
    }else {
      return false;
    }
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isMobile(context) {
    final size = MediaQuery.of(context).size.width;
    if (size < 650 || !kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isTab(context) {
    final size = MediaQuery
        .of(context)
        .size
        .width;
    if (size < 1200 && size >= 600) {
      return true;
    } else {
      return false;
    }
  }

  static bool isDesktop(context) {
    final size = MediaQuery.of(context).size.width;

    if (size >= 1200) {
      return true;
    } else {
      return false;
    }
  }

  static Future showDialogOrBottomSheet(BuildContext context, Widget view) async {
    if(ResponsiveHelper.isDesktop(context)) {
     await showDialog(context: context, builder: (ctx)=> view);
    }else{
     await showModalBottomSheet(backgroundColor: Colors.transparent, context: context, builder: (ctx)=> view);
    }
  }
}