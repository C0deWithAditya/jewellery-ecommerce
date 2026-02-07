import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';

class NetworkInfoHelper {
  final Connectivity connectivity;
  NetworkInfoHelper(this.connectivity);


  static void checkConnectivity(GlobalKey<ScaffoldMessengerState> globalKey) {
    bool firstTime = true;
    Connectivity().onConnectivityChanged.listen(((List<ConnectivityResult> result) async {
      if(!firstTime) {
        bool isNotConnected = result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi);

        isNotConnected ? const SizedBox() : globalKey.currentState?.hideCurrentSnackBar();
        globalKey.currentState?.showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? getTranslated('no_connection', globalKey.currentContext!): getTranslated('connected', globalKey.currentContext!),
            textAlign: TextAlign.center,
          ),
        ));
      }
      firstTime = false;
    }));
  }
}
