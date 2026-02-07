import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/common/widgets/pluto_menu_bar_widget.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:provider/provider.dart';

class MenuBarWidget extends StatelessWidget {
  const MenuBarWidget({super.key});


  List<MenuItems> getMenus(BuildContext context) {
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    return [
      MenuItems(
        title: getTranslated('home', context),
        icon: Icons.home_filled,
        onTap: () => RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.push),
      ),
      MenuItems(
        title: getTranslated('offer', context),
        icon: Icons.local_offer_outlined,
        onTap: () => RouteHelper.getSearchResultRoute(context, shortBy: SearchShortBy.offerProducts, action: RouteAction.push),
      ),
      MenuItems(
        title: getTranslated('necessary_links', context),
        icon: Icons.settings,
        children: [
          MenuItems(
            title: getTranslated('privacy_policy', context),
            onTap: () =>  RouteHelper.getPolicyRoute(context, action: RouteAction.push),
          ),
          MenuItems(
            title: getTranslated('terms_and_condition', context),
            onTap: () => RouteHelper.getTermsRoute(context, action: RouteAction.push),
          ),
          MenuItems(
            title: getTranslated('about_us', context),
            onTap: () => RouteHelper.getAboutUsRoute(context, action: RouteAction.push),
          ),

        ],
      ),
      MenuItems(
        title: getTranslated('favourite', context),
        icon: Icons.favorite_border,
        onTap: () => RouteHelper.getDashboardRoute(context, 'favourite', action: RouteAction.push),
      ),

      MenuItems(
        title: getTranslated('menu', context),
        icon: Icons.menu,
        onTap: () => RouteHelper.getDashboardRoute(context, 'menu', action: RouteAction.push),
      ),

      isLoggedIn ?  MenuItems(
        title: getTranslated('profile', context),
        icon: Icons.person,
        onTap: () => RouteHelper.getProfileRoute(context, action: RouteAction.push),
      ):  MenuItems(
        title: getTranslated('login', context),
        icon: Icons.lock,
        onTap: () => RouteHelper.getLoginRoute(context, action: RouteAction.push),
      ),
      MenuItems(
        title: '',
        icon: Icons.shopping_cart,
        onTap: () => RouteHelper.getDashboardRoute(context, 'cart', action: RouteAction.push),
      ),

    ];
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      //color: Colors.white,
    width: 700,
      child: PlutoMenuBarWidget(
        backgroundColor: Theme.of(context).cardColor,
        gradient: false,
        goBackButtonText: 'Back',
        textStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        moreIconColor: Theme.of(context).textTheme.bodyLarge!.color,
        menuIconColor: Theme.of(context).textTheme.bodyLarge!.color,
        menus: getMenus(context),

      ),
    );
  }
}