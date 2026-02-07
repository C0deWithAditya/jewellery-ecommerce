import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:flutter/material.dart';
class AddressAddButtonWidget extends StatelessWidget {
  final Function onTap;
  const AddressAddButtonWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
      child: OnHover(
        child: InkWell(
          onTap: onTap as void Function()?,
          hoverColor: Colors.transparent,
          child: Container(
            width: 145.0,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(30.0)),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(
              children: [
                const Icon(Icons.add_circle, color: Colors.white),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(getTranslated('add_new_address', context), style: rubikRegular.copyWith(
                  color: Colors.white, fontSize: Dimensions.fontSizeSmall,
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}