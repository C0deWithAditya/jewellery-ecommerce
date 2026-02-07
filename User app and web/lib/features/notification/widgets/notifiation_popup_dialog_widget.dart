import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:hexacom_user/common/models/notification_body.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';

class NotificationPopUpDialogWidget extends StatefulWidget {
  final NotificationBody notificationBody;
  const NotificationPopUpDialogWidget(this.notificationBody, {super.key});

  @override
  State<NotificationPopUpDialogWidget> createState() => _NewRequestDialogState();
}

class _NewRequestDialogState extends State<NotificationPopUpDialogWidget> {

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print("Notification data => ${widget.notificationBody.toJson()}");
    }

    _startAlarm();
  }

  void _startAlarm() async {
    AudioPlayer audio = AudioPlayer();
    audio.play(AssetSource('notification.wav'));
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
      //insetPadding: EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Icon(Icons.notifications_active, size: 60, color: Theme.of(context).primaryColor),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: CustomDirectionalityWidget(child: Text(
                '${widget.notificationBody.title} ${widget.notificationBody.orderId ?? ""}',
                textAlign: TextAlign.center,
                style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              )),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Column(
              children: [
                Text(
                  widget.notificationBody.body!, textAlign: TextAlign.center,
                  style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                if(widget.notificationBody.image != null)
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                if(widget.notificationBody.image != null)
                InkWell(
                  onTap: () {
                    showDialog(context: context, builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
                        child: Container(
                          width: 700,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [

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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CustomImageWidget(
                                image: widget.notificationBody.userImage!,
                                width: 700, fit: BoxFit.cover,
                              ),
                            ),
                          ]),
                        ),
                      );
                    },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomImageWidget(
                      image: widget.notificationBody.userImage ?? widget.notificationBody.image ?? '',
                      height: 200, width: 500, fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [

            Flexible(
              child: SizedBox(width: 120, height: 40,
                child: CustomButtonWidget(
                  backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3),
                  btnTxt: getTranslated('cancel', context),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const SizedBox(width: 20),

            Flexible(
              child: SizedBox(
                width: 120,
                height: 40,
                child: CustomButtonWidget(
                  btnTxt: getTranslated('go', context),
                  onTap: () {
                    Navigator.pop(context);

                    if (kDebugMode) {
                      print("Notification Type => ${widget.notificationBody.type}");
                    }

                    try{
                      if(widget.notificationBody.type == 'general'){
                        RouteHelper.getNotificationRoute(context, action: RouteAction.push);
                      }else if(widget.notificationBody.type == 'message') {



                        RouteHelper.getChatRoute(context, orderId: widget.notificationBody.orderId,
                          userName: widget.notificationBody.userName, profileImage: widget.notificationBody.userImage, action: RouteAction.push,
                        );
                      }
                      else if(widget.notificationBody.type == 'order') {
                        RouteHelper.getOrderDetailsRoute(context, widget.notificationBody.orderId, null);
                      }else{
                        RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
                      }

                    }catch (e) {
                      debugPrint('error ===> $e');
                    }

                  },
                ),
              ),
            ),

          ]),

        ]),
      ),
    );
  }
}
