import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';

class CustomAlertDialogWidget extends StatelessWidget {
  final String? image;
  final IconData? icon;
  final String? title;
  final String? subTitle;
  final String? leftButtonText;
  final String? rightButtonText;
  final Function? onPressLeft;
  final Function? onPressRight;
  final Color? iconColor;
  final Widget? child;
  final Widget? iconWidget;
  final bool? isLoading;
  final Color? buttonColor;

  const CustomAlertDialogWidget({
    super.key, this.image, this.icon,
    this.title, this.subTitle, this.leftButtonText,
    this.rightButtonText, this.onPressLeft,  this.onPressRight,
    this.iconColor, this.child, this.isLoading = false, this.buttonColor, this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return _CustomAlertDialogShape(
      child: child ?? Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeLarge,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        width: ResponsiveHelper.isDesktop(context) ? (Dimensions.webScreenWidth / 2) : MediaQuery.sizeOf(context).width,
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: Dimensions.paddingSizeLarge),

          if(image != null) CustomAssetImageWidget(image!, width: 50),

          if(icon != null) Icon(icon!, size: 50, color: iconColor ?? Theme.of(context).colorScheme.error),

          if(iconWidget != null) iconWidget!,

          const SizedBox(height: Dimensions.paddingSizeDefault),

         if(title != null) Text(title!, style: rubikBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
          ), textAlign: TextAlign.center),
          const SizedBox(height: Dimensions.paddingSizeDefault),


          if(subTitle != null) Text(subTitle!, style: rubikRegular.copyWith(
            fontSize: Dimensions.fontSizeLarge,
          ), textAlign: TextAlign.center),

          const SizedBox(height: 50),


          Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(child: SizedBox(
              width: ResponsiveHelper.isDesktop(context) ? 120 : null,
              child: CustomButtonWidget(
                backgroundColor: Theme.of(context).disabledColor.withOpacity(0.2),
                btnTxt: leftButtonText ?? getTranslated('no', context),
                style: rubikMedium.copyWith(color: Theme.of(context).textTheme.titleMedium?.color, fontSize: Dimensions.fontSizeLarge),
                onTap: onPressLeft ?? ()=> Navigator.pop(context),
              ),
            )),
            const SizedBox(width: Dimensions.paddingSizeDefault),


            Flexible(child: SizedBox(
              width: ResponsiveHelper.isDesktop(context) ? 120 : null,
              child: CustomButtonWidget(
                backgroundColor: buttonColor,
                isLoading: isLoading ?? false,
                btnTxt:  rightButtonText ?? getTranslated('yes', context),
                onTap: onPressRight ?? ()=> Navigator.pop(context),
              ),
            )),

          ]),




        ]),
      ),
    );
  }
}


class _CustomAlertDialogShape extends StatelessWidget {
  final Widget child;
  const _CustomAlertDialogShape({required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(width: 400, child: Stack(
        children: [
          child,
          Positioned.fill(child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Align(alignment: Alignment.topRight, child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              onTap: ()=> Navigator.pop(context),
              child: Icon(Icons.cancel, color: Theme.of(context).colorScheme.error),
            )),
          ))
        ],
      )),
    ) : Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: ResponsiveHelper.isMobile(context)
            ? const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
            : const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 4, width: 40, decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(25),
          )),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          child,

        ],
      ),
    );
  }
}
