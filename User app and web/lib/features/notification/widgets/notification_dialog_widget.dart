import 'package:flutter/material.dart';
import 'package:hexacom_user/features/notification/domain/models/notification_model.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class NotificationDialogWidget extends StatelessWidget {
  final NotificationModel notificationModel;
  const NotificationDialogWidget({Key? key, required this.notificationModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: SizedBox(width: 300, child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          Container(
            height: 150, width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).primaryColor.withOpacity(0.20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FadeInImage.assetNetwork(
                placeholder: Images.placeholder(context),
                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.notificationImageUrl}/${notificationModel.image}',
                height: 150, width: MediaQuery.of(context).size.width,
                imageErrorBuilder: (c,b,v)=> Image.asset(Images.placeholder(context),height: 150, width: MediaQuery.of(context).size.width,fit: BoxFit.cover),

              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(
              notificationModel.title!,
              textAlign: TextAlign.center,
              style: rubikMedium.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Text(
              notificationModel.description!,
              textAlign: TextAlign.center,
              style: rubikRegular.copyWith(
                color: ColorResources.getGreyBunkerColor(context).withOpacity(.75),
              ),
            ),
          ),

        ],
      )),

    );
  }
}
