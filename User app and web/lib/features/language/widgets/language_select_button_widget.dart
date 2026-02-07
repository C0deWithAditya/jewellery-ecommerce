import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/features/onboarding/providers/onboarding_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/provider/language_provider.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelectButtonWidget extends StatelessWidget {
  final bool fromMenu;

  const LanguageSelectButtonWidget({Key? key, required this.fromMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OnBoardingProvider onBoardingProvider = Provider.of<OnBoardingProvider>(context, listen: false);
    final LocalizationProvider localizationProvider =  Provider.of<LocalizationProvider>(context, listen: false);

    return Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) => Center(
          child: Container(
            width: Dimensions.webScreenWidth,
            padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge),
            child: CustomButtonWidget(
              btnTxt: getTranslated('save', context),
              onTap: () {
                Provider.of<SplashProvider>(context, listen: false).disableLang();

                int index = AppConstants.languages.indexWhere((language) =>
                language.imageUrl == languageProvider.selectedLanguageModel?.imageUrl &&
                    language.languageName == languageProvider.selectedLanguageModel?.languageName &&
                    language.countryCode == languageProvider.selectedLanguageModel?.countryCode &&
                    language.languageCode == languageProvider.selectedLanguageModel?.languageCode);



                
                if(languageProvider.languages.isNotEmpty && (index != -1 || languageProvider.selectIndex != 1)) {

                  if(index != -1){
                    localizationProvider.setLanguage(Locale(
                      AppConstants.languages[index].languageCode!,
                      AppConstants.languages[index].countryCode,
                    ));
                    languageProvider.setSelectIndex(index);

                  }else if(languageProvider.selectIndex != -1){
                    localizationProvider.setLanguage(Locale(
                      AppConstants.languages[languageProvider.selectIndex!].languageCode!,
                      AppConstants.languages[languageProvider.selectIndex!].countryCode,
                    ));
                    languageProvider.setSelectIndex(languageProvider.selectIndex);
                  }


                  if (fromMenu) {
                    Navigator.pop(context);
                  } else {

                    ResponsiveHelper.isMobile(context) && !onBoardingProvider.showOnBoardingStatus
                        ? RouteHelper.getOnBoardingRoute(context, action: RouteAction.pushReplacement) : RouteHelper.getMainRoute(context, action: RouteAction.pushReplacement);
                  }
                }else {
                  showCustomSnackBar(getTranslated('select_a_language', context), context);
                }

              },
            ),
          ),
        ));
  }
}
