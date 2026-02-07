import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';

class SupportCardWidget extends StatelessWidget {
  final String title;
  final String icon;
  final Function onTap;
  const SupportCardWidget({
    Key? key, required this.title, required this.icon, required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=> onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05), width: 1),
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          color: Theme.of(context).canvasColor,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(title, style: rubikRegular,)),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          CustomAssetImageWidget(icon, color: Theme.of(context).primaryColor,),
        ]),
      ),
    );
  }
}
