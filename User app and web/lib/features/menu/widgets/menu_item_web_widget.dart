import 'package:hexacom_user/features/menu/domain/models/menu_model.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter/material.dart';


class MenuItemWebWidget extends StatelessWidget {
  final MenuModel menu;
  const MenuItemWebWidget({Key? key, required this.menu}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(32.0),
        onTap: () => menu.route(),
        child: Container(
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.04), borderRadius: BorderRadius.circular(32.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CustomAssetImageWidget(menu.icon, height: 40, width: 40, color: Theme.of(context).textTheme.titleMedium?.color),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(menu.title!, style: rubikRegular),
            ],
          ),
        ),
      );
  }
}
