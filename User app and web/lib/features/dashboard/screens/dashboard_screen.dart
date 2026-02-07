
import 'package:hexacom_user/features/home/screens/home_screen.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/network_info_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/third_party_chat_widget.dart';
import 'package:hexacom_user/features/cart/screens/cart_screen.dart';
import 'package:hexacom_user/features/menu/screens/menu_screen.dart';
import 'package:hexacom_user/features/wishlist/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({Key? key, required this.pageIndex}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;

  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();


  @override
  void initState() {
    super.initState();

    final splashProvider = Provider.of<SplashProvider>(context, listen: false);

    if(splashProvider.policyModel == null) {
      Provider.of<SplashProvider>(context, listen: false).getPolicyPage();
    }
    HomeScreen.loadData(Get.context!,  false);

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const CartScreen(),
      const WishListScreen(),
      const MenuScreen(),
    ];

    if(ResponsiveHelper.isMobilePhone()) {
      NetworkInfoHelper.checkConnectivity(_scaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {

    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
        floatingActionButton: !ResponsiveHelper.isDesktop(context) && _pageIndex == 0
            ?  const ThirdPartyChatWidget() :
        const SizedBox(),
        bottomNavigationBar: !ResponsiveHelper.isDesktop(context) ? Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 7, offset: const Offset(0, 3))],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: BottomNavigationBar(
              backgroundColor: Theme.of(context).cardColor,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Theme.of(context).dividerColor,
              showUnselectedLabels: true,
              currentIndex: _pageIndex,
              type: BottomNavigationBarType.fixed,
              elevation: 10,
              items: [
                _barItem(Icons.home_filled, getTranslated('home', context), 0),
                _barItem(Icons.shopping_cart, getTranslated('cart', context), 1),
                _barItem(Icons.favorite, getTranslated('favourite', context), 2),
                _barItem(Icons.menu, getTranslated('menu', context), 3)
              ],
              onTap: (int index) {
                _setPage(index);
              },
            ),
          ),
        ) : const SizedBox(),

        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _barItem(IconData icon, String? label, int index) {
    return BottomNavigationBarItem(

      icon: Consumer<WishListProvider>(
        builder: (context, wishListProvider, _) {
          return Stack(
            clipBehavior: Clip.none, children: [
            Icon(icon, color: index == _pageIndex ? Theme.of(context).primaryColor : Theme.of(context).dividerColor, size: 25),
            (index == 1 || (index == 2 && wishListProvider.wishList != null && wishListProvider.wishList!.isNotEmpty))  ? Positioned(
              top: -7, right: -7,
              child: Container(
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _pageIndex ? Colors.red : Theme.of(context).primaryColor,
                ),
                child: Text(
                  index == 1 ? CartHelper.getCartItemCount(
                    Provider.of<CartProvider>(context).cartList,
                  ).toString() : '${wishListProvider.wishList?.length}',
                  style: rubikMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ) : const SizedBox(),
          ],
          );
        }
      ),
      label: label,
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
