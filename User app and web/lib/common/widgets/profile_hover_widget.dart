import 'package:hexacom_user/features/menu/domain/models/menu_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/text_hover_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileHoverWidget extends StatelessWidget {
  const ProfileHoverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<MenuModel> list = [
      MenuModel(icon: Images.profile, title: getTranslated('profile', context), route: ()=> RouteHelper.getProfileRoute(context)),
      MenuModel(icon: Images.order, title: getTranslated('my_orders', context), route: ()=> RouteHelper.getOrderListScreen(context)),
      MenuModel(icon: Images.profile, title: getTranslated('log_out', context), route: ()=> RouteHelper.getLoginRoute(context)),
    ];


    return Selector<AuthProvider, bool>(
      selector: (context, authProvider) => authProvider.isLoading,
      builder: (context, isLoading, child) {
        return Container(color: Theme.of(context).cardColor, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.map((item) => InkWell(
            onTap: (){
              if(item.title == getTranslated('log_out', context)){


                Future.delayed(const Duration(seconds: 0), () => ResponsiveHelper.showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                  isLoading: isLoading ,
                  title: getTranslated('want_to_sign_out', context),
                  icon: Icons.contact_support_outlined,
                  onPressRight: (){
                    Provider.of<AuthProvider>(context, listen: false).clearSharedData();
                    if(ResponsiveHelper.isWeb()) {
                      RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushNamedAndRemoveUntil);
                    }else {
                      RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushNamedAndRemoveUntil);
                    }
                  },

                )));

              }else{
                 item.route();
              }

            },
            child: TextHoverWidget(builder: (isHover)=> Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: isHover ? Theme.of(context).focusColor : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Text(item.title ?? '', overflow: TextOverflow.ellipsis, maxLines: 1, style: rubikRegular),
                ),

                Divider(height: 1, color: (list.indexOf(item) + 1) != list.length ? null : Theme.of(context).cardColor),
              ]),
            )),
          )).toList(),
        ));
      }
    );
  }
}
