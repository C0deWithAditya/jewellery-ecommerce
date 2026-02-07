import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/not_logged_in_screen.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/features/wishlist/widgets/wish_list_shimmer_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    return Scaffold(
      appBar:(ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) : CustomAppBarWidget(title: getTranslated('favourite_list', context), isBackButtonExist: !ResponsiveHelper.isMobile(context))) as PreferredSizeWidget?,
      body: isLoggedIn ? Consumer<WishListProvider>(
        builder: (context, wishlistProvider, child) {
          return wishlistProvider.isLoading ? const WishLIstShimmerWidget() : !wishlistProvider.isLoading && wishlistProvider.wishIdList.isEmpty ?  NoDataScreen(
            showFooter: true, title: getTranslated('no_favourite_added_yet', context), image: Images.wishListNoData, scrollable: true,
          ) : RefreshIndicator(
              color: Theme.of(context).secondaryHeaderColor,
              onRefresh: () async {
                await Provider.of<WishListProvider>(context, listen: false).getWishList();
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                        width: Dimensions.webScreenWidth,
                        child: ResponsiveHelper.isDesktop(context) ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                            mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                            childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 4,
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1,
                          ),
                          itemCount: wishlistProvider.wishList!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          itemBuilder: (context, index) {
                            return ProductCardWidget(product: wishlistProvider.wishList![index]);
                          },
                        ) : StaggeredGrid.count(
                        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : 2,
                        mainAxisSpacing: 4, crossAxisSpacing: 4,
                        children: wishlistProvider.wishList!.map((product) => StaggeredGridTile.fit(
                          crossAxisCellCount: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ProductCardWidget(product: product),
                          ),
                        ),).toList()),

                      ),
                    ),

                    const FooterWebWidget(footerType: FooterType.nonSliver),
                  ],
                ),
              )
          );
        },
      ) : const NotLoggedInScreen(),
    );
  }
}

