
import 'package:hexacom_user/common/enums/popup_menu_type_enum.dart';
import 'package:hexacom_user/common/widgets/cart_count_widget.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:hexacom_user/common/widgets/profile_hover_widget.dart';
import 'package:hexacom_user/common/widgets/theme_switch_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../models/language_model.dart';
import '../../localization/language_constrants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/category/providers/category_provider.dart';
import '../../provider/language_provider.dart';
import '../../provider/localization_provider.dart';
import '../../features/product/providers/product_provider.dart';
import '../../features/search/providers/search_provider.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../utill/app_constants.dart';
import '../../utill/dimensions.dart';
import '../../utill/images.dart';
import '../../utill/routes.dart';
import '../../utill/styles.dart';
import 'custom_text_field_widget.dart';
import 'text_hover_widget.dart';
import 'category_hover_widget.dart';
import 'language_hover_widget.dart';


class WebAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const WebAppBarWidget({super.key});


  @override
  State<WebAppBarWidget> createState() => _WebAppBarWidgetState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _WebAppBarWidgetState extends State<WebAppBarWidget> {
  String? chooseLanguage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageProvider>(context, listen: false).initializeAllLanguages(context);
    LanguageModel currentLanguage = AppConstants.languages.firstWhere((language) => language.languageCode == Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);


    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0,10),
              )
            ],
          ),
          child: Column(children: [

            Container(
              color: Theme.of(context).secondaryHeaderColor.withOpacity(themeProvider.darkTheme ? 0.2 : 0.5), height: 30,
              child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    const ThemeSwitchButtonWidget(),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    Selector<LocalizationProvider, String>(
                      selector: (context, localizationProvider) => localizationProvider.locale.languageCode,
                      builder: (context, languageCode, child) {
                        return SizedBox(height: Dimensions.paddingSizeLarge, child: MouseRegion(
                          onHover: (details)=> _showPopupMenu(details.position, context, PopupMenuType.language),
                          child: Row(children: [
                            Text(languageCode.toUpperCase(), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Icon(
                              Icons.expand_more, color: Theme.of(context).textTheme.bodyMedium?.color,
                              size: Dimensions.paddingSizeLarge,
                            )
                          ]),
                        ));
                      }
                    ),


                    const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                  ],
                ),
              ))),

            ),

            Expanded(child: Container(color: Theme.of(context).cardColor, child: Center(child: SizedBox(
              width: Dimensions.webScreenWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: [
                    InkWell(
                      onTap: () {
                        Provider.of<ProductProvider>(context, listen: false).offset = 1;
                        RouteHelper.getMainRoute(context);
                      },
                      child: Consumer<SplashProvider>(builder:(context, splash, child) => Row(children: [
                            SizedBox(height: 30, width: 30, child: CustomImageWidget(
                              placeholder: Images.logo,
                              image: splash.baseUrls != null ? '${splash.baseUrls!.ecommerceImageUrl}/${splash.configModel!.appLogo}' : '',
                              fit: BoxFit.contain,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            FittedBox(
                              child: Text(
                                splash.configModel?.ecommerceName ??  AppConstants.appName,
                                style: rubikBold.copyWith(fontSize: 25, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ])),
                    ),
                    const SizedBox(width: 40),

                    TextHoverWidget(builder: (isHovered)=> OnHover(
                      child: InkWell(
                        onTap: (){
                          Provider.of<ProductProvider>(context, listen: false).offset = 1;
                          RouteHelper.getDashboardRoute(context, 'home');
                        },
                        child: Text(getTranslated('home', context), style: rubikMedium.copyWith(
                          color: isHovered ? Theme.of(context).primaryColor : null,
                        )),
                      ),
                    )),
                    const SizedBox(width: 25),

                    TextHoverWidget(builder: (isHovered)=> OnHover(
                      child: MouseRegion(
                          onHover: (details){
                            if(Provider.of<CategoryProvider>(context, listen: false).categoryList != null) {
                              _showPopupMenu(details.position, context, PopupMenuType.category);
                            }
                          },
                          child: Row(children: [
                            Text(getTranslated('categories', context), style: rubikMedium),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Icon(Icons.expand_more, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault),

                          ])),
                    )),
                  ],),

                  Row(children: [
                    TextHoverWidget(builder: (isHover)=> Container(
                      width: 400, height: 41,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
                      ),
                      child: Consumer<SearchProvider>(builder: (context, search,_)=> Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.07), width: 1),
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge)
                        ),
                        child: CustomTextFieldWidget(
                          contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                          hintText: getTranslated('search_items_here', context),
                          hintFontSize: Dimensions.fontSizeSmall,
                          fillColor: Colors.transparent,
                          isShowSuffixIcon: true,
                          isIcon: true,
                          suffixAssetUrl: search.isSearch ? Images.search : Images.close,
                          onChanged: (str){
                            str.length = 0;
                            search.getSearchText(str);

                          },

                          onSuffixTap: () {
                            if(search.searchController.text.isNotEmpty && search.isSearch == true){
                              Provider.of<SearchProvider>(context,listen: false).saveSearchAddress(search.searchController.text);
                              RouteHelper.getSearchResultRoute(context, text: search.searchController.text);

                              search.changeSearchStatus();

                            }
                            else if (search.searchController.text.isNotEmpty && search.isSearch == false) {
                              search.searchController.clear();
                              search.getSearchText('');

                              search.changeSearchStatus();
                            }
                          },
                          controller: search.searchController,
                          inputAction: TextInputAction.search,
                          onSubmit: (text) {
                            if (search.searchController.text.isNotEmpty) {
                              Provider.of<SearchProvider>(context,listen: false).saveSearchAddress(search.searchController.text);
                              RouteHelper.getSearchResultRoute(context, text: search.searchController.text);

                              search.changeSearchStatus();
                            }

                          },),
                      )),

                    )),

                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    OnHover(child: InkWell(
                      onTap: () => RouteHelper.getCouponRoute(context, action: RouteAction.push),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Row(children: [
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Image.asset(Images.coupon, height: 16),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Text(getTranslated('coupon', context), style: rubikMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: themeProvider.darkTheme ? Theme.of(context).primaryColor : Theme.of(context).textTheme.titleMedium?.color,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        ]),
                      ),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    OnHover(child: InkWell(
                      onTap: () => RouteHelper.getDashboardRoute(context, 'favourite'),
                      child: Consumer<WishListProvider>(builder: (context, wishListProvider, _)=> CartCountWidget(
                        count: wishListProvider.wishList?.length ?? 0, icon: Icons.favorite,
                      )),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    OnHover(child: InkWell(
                      onTap: () => RouteHelper.getDashboardRoute(context, 'cart', action: RouteAction.push),
                      child: Consumer<CartProvider>(builder: (context, cartProvider, _)=> CartCountWidget(
                        count: CartHelper.getCartItemCount(cartProvider.cartList), icon: Icons.shopping_cart,
                      )),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    Consumer<AuthProvider>(builder: (context, authProvider, _)=> InkWell(
                      onTap: () => !authProvider.isLoggedIn() ? RouteHelper.getLoginRoute(context) : (){},
                      child: TextHoverWidget(builder: (isHover)=> OnHover(child: MouseRegion(
                          onHover: (details){
                            if(authProvider.isLoggedIn()) {
                              _showPopupMenu(details.position, context, PopupMenuType.profile);
                            }
                          },
                          child: authProvider.isLoggedIn() ? Consumer<ProfileProvider>(
                              builder: (context, profileProvider, child) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeFifty),
                                  child: CustomImageWidget(
                                    image: '${splashProvider.baseUrls!.customerImageUrl}/${profileProvider.userInfoModel != null ? profileProvider.userInfoModel!.image : ''}',
                                    placeholder: Images.profile,
                                    height: 24,
                                    width: 24,
                                  ),
                                );
                              }
                          ) : Image.asset(
                            Images.profile, height: 24,
                            width: 24,
                            color: isHover ? Theme.of(context).primaryColor : Theme.of(context).focusColor,
                          )))),

                    )),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    OnHover(child: IconButton(
                      onPressed: () => RouteHelper.getDashboardRoute(context, 'menu', action: RouteAction.push),
                      icon: Icon(Icons.menu, size: Dimensions.paddingSizeExtraLarge, color: Theme.of(context).primaryColor),
                    )),


                  ])

                ],
              ),
            )))),


          ]),
        );
      }
    );
  }

  Size get preferredSize => const Size(double.maxFinite, 160);


  List<PopupMenuEntry<Object>> _categoryPopupList(BuildContext context) {
    List<PopupMenuEntry<Object>> list = <PopupMenuEntry<Object>>[];
    List<CategoryModel>? categoryList =  Provider.of<CategoryProvider>(context, listen: false).categoryList;
    list.add(
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: categoryList,
          child: MouseRegion(
            onExit: (_)=> Navigator.of(context).pop(),
            child: CategoryHoverWidget(categoryList: categoryList),
          ),
        ));
    return list;
  }

  List<PopupMenuEntry<Object>> _popUpLanguageList(BuildContext context) {
    List<PopupMenuEntry<Object>> languagePopupMenuEntryList = <PopupMenuEntry<Object>>[];
    List<LanguageModel> languageList =  AppConstants.languages;
    languagePopupMenuEntryList.add(
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: languageList,
          child: MouseRegion(
            onExit: (_)=> Navigator.of(context).pop(),
            child: LanguageHoverWidget(languageList: languageList),
          ),
        ));
    return languagePopupMenuEntryList;
  }

  List<PopupMenuEntry<Object>> _profilePopUpMenuList(BuildContext context) {
    List<PopupMenuEntry<Object>> profilePopupMenuEntryList = <PopupMenuEntry<Object>>[];
    profilePopupMenuEntryList.add(
        const PopupMenuItem(
          padding: EdgeInsets.zero,
          child: MouseRegion(
            child: ProfileHoverWidget(),
          ),
        ));
    return profilePopupMenuEntryList;
  }


  List<PopupMenuEntry<Object>> _getPopupItems(PopupMenuType type){
    switch (type) {
      case PopupMenuType.language:
        return _popUpLanguageList(context);
      case PopupMenuType.category:
        return _categoryPopupList(context);
      case PopupMenuType.profile:
        return _profilePopUpMenuList(context);
    }
  }

  void _showPopupMenu(Offset offset, BuildContext context, PopupMenuType type) async {
    double left = offset.dx;
    double top = offset.dy;

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, overlay.size.width, overlay.size.height),
      items: _getPopupItems(type),
      elevation: 8.0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),

    );
  }
}


