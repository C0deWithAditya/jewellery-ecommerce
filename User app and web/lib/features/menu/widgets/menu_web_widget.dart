import 'package:go_router/go_router.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/menu/widgets/menu_item_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/models/menu_model.dart';
import '../../auth/providers/auth_provider.dart';

class MenuWebWidget extends StatelessWidget {
  final bool? isLoggedIn;
  const MenuWebWidget({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final splashProvider =  Provider.of<SplashProvider>(context, listen: false);


    final List<MenuModel> menuList = [
      MenuModel(icon: Images.couponMenuIcon, title: getTranslated('my_order', context), route: ()=>  RouteHelper.getOrderListScreen(context)),
      MenuModel(icon: Images.trackOrder, title: getTranslated('track_order', context), route: ()=>  RouteHelper.getOrderSearchScreen(context)),
      MenuModel(icon: Images.profileMenuIcon, title: getTranslated('profile', context), route: ()=>  RouteHelper.getProfileRoute(context)),
      MenuModel(icon: Images.address, title: getTranslated('address', context), route: ()=>  RouteHelper.getAddressRoute(context)),
      MenuModel(icon: Images.message, title: getTranslated('message', context), route: ()=>  RouteHelper.getChatRoute(context, orderId: null)),
      MenuModel(icon: Images.couponMenuIcon, title: getTranslated('coupon', context), route: ()=>  RouteHelper.getCouponRoute(context)),
      MenuModel(icon: Images.notification, title: getTranslated('notification', context), route: ()=>  RouteHelper.getNotificationRoute(context)),
      MenuModel(icon: Images.helpSupport, title: getTranslated('help_and_support', context), route: ()=>  RouteHelper.getSupportRoute(context)),
      MenuModel(icon: Images.privacyPolicy, title: getTranslated('privacy_policy', context), route: ()=>  RouteHelper.getPolicyRoute(context)),
      MenuModel(icon: Images.termsAndCondition, title: getTranslated('terms_and_condition', context), route: ()=> RouteHelper.getTermsRoute(context)),

      if(splashProvider.policyModel?.refundPage?.status ?? false)
        MenuModel(icon: Images.refundPolicy, title: getTranslated('refund_policy', context), route: ()=>  RouteHelper.getRefundPolicyRoute(context)),

      if(splashProvider.policyModel?.returnPage?.status ?? false)
        MenuModel(icon: Images.refundPolicy, title: getTranslated('return_policy', context), route: ()=>  RouteHelper.getReturnPolicyRoute(context)),

      if(splashProvider.policyModel?.cancellationPage?.status ?? false)
        MenuModel(icon: Images.cancellationPolicy, title: getTranslated('cancellation_policy', context), route: ()=>  RouteHelper.getCancellationPolicyRoute(context)),

      MenuModel(icon: Images.aboutUs, title: getTranslated('about_us', context), route: ()=>  RouteHelper.getAboutUsRoute(context)),


      MenuModel(icon: Images.login, title: getTranslated(isLoggedIn! ? 'logout' : 'login', context), route: (isLoggedIn ?? false) ? (){

        ResponsiveHelper.showDialogOrBottomSheet(context, Selector<AuthProvider, bool>(
          selector: (context, authProvider) => authProvider.isLoading,
          builder: (context, isLoading, child) {
            return CustomAlertDialogWidget(
              isLoading: isLoading,
              title: getTranslated('want_to_sign_out', context),
              icon: Icons.contact_support_outlined,
              onPressRight: () async{
                await Provider.of<AuthProvider>(context, listen: false).clearSharedData();
                if(ResponsiveHelper.isDesktop(context)) {
                  GoRouter.of(context).pop();
                  RouteHelper.getMainRoute(context, action: RouteAction.push);
                }else {
                  Navigator.pop(context);
                  RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushNamedAndRemoveUntil);
                }
              },
            );
          }
        ));
      } : () => RouteHelper.getLoginRoute(context)),

    ];

    return SingleChildScrollView(
      child: Column(children: [

        Center(child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            return SizedBox(width: Dimensions.webScreenWidth, child: Stack(children: [

              Column(children: [

                Container(height: 150,  color:  Theme.of(context).primaryColor,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 240.0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                    isLoggedIn! ? profileProvider.userInfoModel != null ? Text(
                      '${profileProvider.userInfoModel!.fName ?? ''} ${profileProvider.userInfoModel!.lName ?? ''}',
                      style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.white),
                    ) : const SizedBox(height: Dimensions.paddingSizeDefault, width: 150) :
                    Column(children: [

                      SizedBox(height: (isLoggedIn! && profileProvider.userInfoModel != null) ? 0 : 100),

                      Text(getTranslated('guest', context),
                        style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.white),
                      ),

                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    if(isLoggedIn! && profileProvider.userInfoModel != null) Text(
                      profileProvider.userInfoModel!.email ?? '',
                      style: rubikRegular.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                  ]),

                ),
                const SizedBox(height: 100),

                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: Dimensions.paddingSizeExtraLarge,
                    mainAxisSpacing: Dimensions.paddingSizeExtraLarge,
                  ),
                  itemCount: menuList.length,
                  itemBuilder: (context, index) {
                    return MenuItemWebWidget(
                      menu: menuList[index],
                    );
                  },
                ),
                const SizedBox(height: 50),

              ]),

              Positioned(left: 30, top: 45, child: Builder(
                builder: (context) {
                  return Container(height: 180, width: 180,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 22, offset: const Offset(0, 8.8) )]),
                    child: ClipOval(
                      child: isLoggedIn! ? FadeInImage.assetNetwork(
                        placeholder: Images.placeholder(context), height: 170, width: 170, fit: BoxFit.cover,
                        image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/'
                            '${profileProvider.userInfoModel != null ? profileProvider.userInfoModel!.image : ''}',
                        imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 170, width: 170, fit: BoxFit.cover),

                      ) : Image.asset(Images.placeholder(context), height: 170, width: 170, fit: BoxFit.cover),
                    ),
                  );
                })),

              Positioned(right: 0, top: 140,
                child: isLoggedIn! ? Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: InkWell(
                    onTap: (){
                      ResponsiveHelper.showDialogOrBottomSheet(context, Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return CustomAlertDialogWidget(
                            isLoading: authProvider.isLoading,
                            title: getTranslated('are_you_sure_to_delete_account', context),
                            subTitle: getTranslated('it_will_remove_your_all_information', context),
                            icon: Icons.contact_support_outlined,
                            onPressRight: ()=> authProvider.deleteUser(),
                          );
                        },
                      ));
                    },
                    child: Row(children: [

                      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Icon(Icons.delete, color: Theme.of(context).primaryColor, size: 16),
                      ),

                      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Text(getTranslated('delete_account', context)),
                      ),

                    ],),
                  ),
                ) : const SizedBox(),),

              Positioned.fill(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                child: Align(alignment: Alignment.bottomCenter, child: Text('${getTranslated('version', context)} ${AppConstants.appVersion}', style: rubikMedium.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.4),
                )),),
              ))

            ]));
          },
        )),
        const FooterWebWidget(footerType: FooterType.nonSliver),

      ]),
    );
  }
}