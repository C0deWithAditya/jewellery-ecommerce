import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';

class ThirdPartyChatWidget extends StatefulWidget {
  const ThirdPartyChatWidget({
    super.key,
  });

  @override
  State<ThirdPartyChatWidget> createState() => _ThirdPartyChatWidgetState();

}

class _ThirdPartyChatWidgetState extends State<ThirdPartyChatWidget> {


  List<SpeedDialChild> getDialList(BuildContext context, ConfigModel? configModel){
    List<SpeedDialChild> dialList = [];

    if((configModel != null && configModel.whatsapp != null
        && (configModel.whatsapp?.status ?? false)
        && configModel.whatsapp?.number != null)){

      dialList.add(SpeedDialChild(
        backgroundColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          padding:  const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall,
            horizontal: Dimensions.paddingSizeSmall,
          ),
          height: 35, width: 55,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(Get.context!).primaryColor),
          child: Image.asset(Images.whatsapp),
        ),
        onPressed: () async {
          final String? whatsapp = configModel.whatsapp?.number;
          final Uri whatsappMobile = Uri.parse("whatsapp://send?phone=$whatsapp");
          if (await canLaunchUrl(whatsappMobile)) {
            await launchUrl(whatsappMobile, mode: LaunchMode.externalApplication);
          } else {
            await launchUrl( Uri.parse("https://web.whatsapp.com/send?phone=$whatsapp"), mode: LaunchMode.externalApplication);
          }
        },
      ));
    }


    if((configModel != null && configModel.telegram != null
        && (configModel.telegram?.status ?? false)
        && configModel.telegram?.userName != null)){


      dialList.add(SpeedDialChild(backgroundColor: Colors.transparent,child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraSmall,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        height: 35, width: 55,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Image.asset(Images.telegram),
      ),
        onPressed: () async {
          final String? userName = configModel.telegram?.userName;
          final Uri whatsappMobile = Uri.parse("https://t.me/$userName");
          if (await canLaunchUrl(whatsappMobile)) {
            await launchUrl(whatsappMobile, mode: LaunchMode.externalApplication);
          }
        },)
      );

    }

    if((configModel != null && configModel.messenger != null
        && (configModel.messenger?.status ?? false)
        && configModel.messenger?.userName != null)){

      dialList.add(SpeedDialChild(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall,
            horizontal: Dimensions.paddingSizeSmall,
          ),
          height: 35, width: 55,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
          child: Image.asset(Images.messenger),
        ),
        onPressed: () async {
          final String? userId = configModel.messenger?.userName;
          final Uri messengerUrl = Uri.parse("https://m.me/$userId");
          if (await canLaunchUrl(messengerUrl)) {
            await launchUrl(messengerUrl, mode: LaunchMode.externalApplication);
          }
        },
      ));

    }

    return dialList;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashProvider>(
      builder: (context, splashProvider, _) {
        if(!(splashProvider.configModel?.fetchedFromOnline ?? false))  return const SizedBox();

        List<SpeedDialChild> dialList = getDialList(context, splashProvider.configModel);
        
        return dialList.isEmpty ? const SizedBox() : dialList.length > 1 ?  SpeedDial(
          closedForegroundColor: Colors.white,
          openForegroundColor: Colors.white,
          closedBackgroundColor: Theme.of(context).primaryColor,
          openBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
          labelsBackgroundColor: Colors.white,
          speedDialChildren: dialList,
          child: const Icon(Icons.message),
        ) : InkWell(onTap:()=> dialList.first.onPressed(), child: dialList.first.child);
      }
    );

  }
}
