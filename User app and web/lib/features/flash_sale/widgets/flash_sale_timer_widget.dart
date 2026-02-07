import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlashSaleTimerWidget extends StatelessWidget {
  const FlashSaleTimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashSaleProvider>(
      builder: (context, flashSaleProvider, _) {
        int? days, hours, minutes, seconds;

        if (flashSaleProvider.duration != null) {
          days = flashSaleProvider.duration!.inDays;
          hours = flashSaleProvider.duration!.inHours - days * 24;
          minutes = flashSaleProvider.duration!.inMinutes - (24 * days * 60) - (hours * 60);
          seconds = flashSaleProvider.duration!.inSeconds - (24 * days * 60 * 60) - (hours * 60 * 60) - (minutes * 60);
        }
        return Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          _TimerWidget(
            timeCount: days ?? 0,
            timeUnit: getTranslated('days', context)),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          _TimerWidget(
            timeCount: hours ?? 0,
            timeUnit: getTranslated('hours', context)),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          _TimerWidget(
            timeCount: minutes ?? 0,
            timeUnit: getTranslated('mins', context)),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          _TimerWidget(
            timeCount: seconds ?? 0,
            timeUnit: getTranslated('sec', context)),
          const SizedBox(width: Dimensions.paddingSizeDefault),


        ]);
      }
    );
  }
}


class _TimerWidget extends StatelessWidget {
  final int timeCount;
  final String timeUnit;
  const _TimerWidget({Key? key, required this.timeUnit, required this.timeCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical:Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Text(timeCount > 9 ? timeCount.toString() : '0${timeCount.toString()}' , style: rubikMedium.copyWith(color: Colors.white)),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(timeUnit, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500)),
      ],
    );
  }
}