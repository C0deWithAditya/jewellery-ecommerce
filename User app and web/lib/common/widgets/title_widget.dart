import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';

class TitleWidget extends StatelessWidget {
  final String? title;
  final Function? onTap;
  final Widget? leadingButton;

  const TitleWidget({super.key, required this.title, this.onTap, this.leadingButton});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title!, style: ResponsiveHelper.isDesktop(context) ? rubikMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge) : rubikMedium),

      leadingButton != null ? leadingButton! :  onTap != null ? InkWell(
        onTap: onTap as void Function()?,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
          child: Text(
            getTranslated('view_all', context),
            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
          ),
        ),
      ) : const SizedBox(),
    ]);
  }
}
