import 'dart:io';

import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final splashProvider =  Provider.of<SplashProvider>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            Image.asset(Images.update,
              width: MediaQuery.of(context).size.height*0.4,
              height: MediaQuery.of(context).size.height*0.4,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),

            Text(getTranslated('your_app_is_deprecated', context),
              style: rubikRegular.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175, color: Theme.of(context).disabledColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04),

             CustomButtonWidget(btnTxt: getTranslated('update_now', context), onTap: () async {
              String? appUrl = 'https://google.com';
              if(Platform.isAndroid) {
                appUrl = splashProvider.configModel!.playStoreConfig!.link;
              }else if(Platform.isIOS) {
                appUrl = splashProvider.configModel!.appStoreConfig!.link;
              }
              if(await canLaunchUrlString(appUrl!)) {
                launchUrlString(appUrl, mode: LaunchMode.externalApplication);
              }else {
                showCustomSnackBar('${getTranslated('can_not_launch', Get.context!)} $appUrl', Get.context!);
              }
            }),

          ]),
        ),
      ),
    );
  }
}
