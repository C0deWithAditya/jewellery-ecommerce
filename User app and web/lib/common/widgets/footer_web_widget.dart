import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/helper/email_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/provider/news_provider.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:hexacom_user/common/widgets/text_hover_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../localization/language_constrants.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../utill/app_constants.dart';
import '../../utill/color_resources.dart';
import '../../utill/dimensions.dart';
import '../../utill/images.dart';
import '../../helper/custom_snackbar_helper.dart';
class FooterWebWidget extends StatelessWidget {
  final FooterType footerType;
  const FooterWebWidget({super.key, required this.footerType});

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =  Provider.of<SplashProvider>(context,listen: false).configModel!;

    final List<QuickLinkModel> accountQuickLink = [
      QuickLinkModel(title: getTranslated('profile', context), route: ()=> RouteHelper.getProfileRoute(context)),
      QuickLinkModel(title: getTranslated('address', context), route: ()=> RouteHelper.getAddressRoute(context)),
      QuickLinkModel(title: getTranslated('live_chat', context), route: ()=> RouteHelper.getChatRoute(context)),
      QuickLinkModel(title: getTranslated('order', context), route: ()=> RouteHelper.getOrderListScreen(context)),
    ];
    final List<QuickLinkModel> otherQuickLink = [
      QuickLinkModel(title: getTranslated('contact_us', context), route: ()=> RouteHelper.getSupportRoute(context)),
      QuickLinkModel(title: getTranslated('privacy_policy', context), route: ()=> RouteHelper.getPolicyRoute(context)),
      QuickLinkModel(title: getTranslated('terms_and_condition', context), route: ()=> RouteHelper.getTermsRoute(context)),
      QuickLinkModel(title: getTranslated('about_us', context), route: ()=> RouteHelper.getAboutUsRoute(context)),

    ];

    TextEditingController newsLetterController = TextEditingController();

    return _FooterFormatter(footerType: footerType, child: SizedBox(
      height: 325,
      child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return Consumer<SplashProvider>(builder: (context, splashProvider, _)=> Container(
              color: Theme.of(context).secondaryHeaderColor.withOpacity(themeProvider.darkTheme ? 0.2 : 0.5),
              width: double.maxFinite,
              child: Center(child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Consumer<SplashProvider>(builder:(context, splash, child) => Row(children: [
                            SizedBox(height: 40, child: CustomImageWidget(
                              placeholder: Images.logo,
                              image: splash.baseUrls != null ? '${splash.baseUrls!.ecommerceImageUrl}/${splash.configModel!.appLogo}' : '',
                              fit: BoxFit.contain,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Text(
                              splash.configModel?.ecommerceName ??  AppConstants.appName,
                              style: rubikBold.copyWith(fontSize: 30, color: Theme.of(context).primaryColor),
                            ),
                          ])),


                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text(getTranslated('news_letter', context), style: rubikBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(getTranslated('subscribe_to_out_new_channel_to_get_latest_updates', context), style: rubikRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Container(
                            width: 400,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                  )
                                ]
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                Expanded(child: TextField(
                                  controller: newsLetterController,
                                  style: rubikMedium.copyWith(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: getTranslated('your_email_address', context),
                                    hintStyle: rubikRegular.copyWith(color: ColorResources.getGreyColor(context),fontSize: Dimensions.fontSizeLarge),
                                    border: InputBorder.none,
                                  ),
                                  maxLines: 1,

                                )),
                                InkWell(
                                  onTap: (){
                                    String email = newsLetterController.text.trim().toString();
                                    if (email.isEmpty) {
                                      showCustomSnackBar(getTranslated('enter_email_address', context), context);
                                    }else if (EmailCheckerHelper.isNotValid(email)) {
                                      showCustomSnackBar(getTranslated('enter_valid_email', context), context);
                                    }else{
                                      Provider.of<NewsLetterProvider>(context, listen: false).addToNewsLetter(email).then((value) {
                                        newsLetterController.clear();
                                      });
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                    child: Text(getTranslated('subscribe', context), style: rubikRegular.copyWith(color: Colors.white,fontSize: Dimensions.fontSizeDefault)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          // const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),


                        ],
                      )),

                      if(configModel.playStoreConfig!.status! || configModel.appStoreConfig!.status!)
                        Expanded(flex: 4, child: Column(children: [
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text(
                            configModel.playStoreConfig!.status! && configModel.appStoreConfig!.status! ? getTranslated('download_our_apps', context): getTranslated('download_our_app', context),
                            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Column(children: [

                            if(configModel.playStoreConfig!.status!) InkWell(
                              onTap:()=> _launchURL(configModel.playStoreConfig!.link!),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(Images.playStore,height: 50, fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            if(configModel.appStoreConfig!.status!) InkWell(
                              onTap:()=> _launchURL(configModel.appStoreConfig!.link!),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(Images.appStore,height: 50,fit: BoxFit.contain),
                              ),
                            ),
                          ])
                        ])),

                      Expanded(flex: 2,child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Text(getTranslated('my_account', context).toUpperCase(), style: rubikMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: accountQuickLink.map((link) => OnHover(
                            child: TextHoverWidget(builder: (hovered)=> Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: InkWell(
                                onTap: ()=> link.route(),
                                child: Text(link.title, style: rubikSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                )),
                              ),
                            )),
                          )).toList()),


                        ],)),
                      Expanded(flex: 2,child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Text(getTranslated('quick_links', context).toUpperCase(), style: rubikMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: otherQuickLink.map((link) => OnHover(
                            child: TextHoverWidget(builder: (hovered)=> Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: InkWell(
                                onTap: ()=> link.route(),
                                child: Text(link.title, style: rubikSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                )),
                              ),
                            )),
                          )).toList()),

                        ],)),
                    ],
                  ),

                  const Divider(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  SizedBox(height: 30, child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(splashProvider.configModel!.socialMediaLink!.isNotEmpty)  Text(getTranslated('follow_us_on', context), style: rubikMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        SizedBox(height: Dimensions.paddingSizeLarge,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: splashProvider.configModel!.socialMediaLink!.length,
                              itemBuilder: (BuildContext context, index){
                                return  splashProvider.configModel!.socialMediaLink!.isNotEmpty ?
                                InkWell(
                                  onTap: (){
                                    _launchURL(splashProvider.configModel!.socialMediaLink![index].link!);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Image.asset(
                                      Images.getSocialImage(splashProvider.configModel!.socialMediaLink![index].name!),
                                      height: Dimensions.paddingSizeExtraLarge,
                                      width: Dimensions.paddingSizeExtraLarge,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ):const SizedBox();

                              }),
                        ),
                      ],
                    ),

                    Text(
                      configModel.footerCopyright ?? '${getTranslated('copyright', context)} ${configModel.ecommerceName}',
                      style: rubikRegular, maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),

                  ])),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                ]),
              )),
            ));
          }
      ),
    ));

  }
}
_launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url, );
  } else {
    throw 'Could not launch $url';
  }
}


class QuickLinkModel{
  final String title;
  final Function route;

  QuickLinkModel({required this.title, required this.route});
}

class _FooterFormatter extends StatelessWidget {
  final Widget child;
  final FooterType footerType;
  const _FooterFormatter({required this.child, required this.footerType});


  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? footerType == FooterType.nonSliver ? child : SliverFillRemaining(
      hasScrollBody: false,
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),
        child,
      ]),
    ) : footerType == FooterType.sliver ? const SliverToBoxAdapter() :  const SizedBox();
  }
}
