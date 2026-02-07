import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../localization/language_constrants.dart';
import '../../../../provider/localization_provider.dart';
import '../../../../utill/color_resources.dart';
import '../../../../utill/dimensions.dart';
import '../models/language_model.dart';
import '../../features/category/providers/category_provider.dart';
import '../../provider/language_provider.dart';
import '../../features/product/providers/product_provider.dart';
import '../../helper/custom_snackbar_helper.dart';
import 'text_hover_widget.dart';

class LanguageHoverWidget extends StatelessWidget {
  final List<LanguageModel> languageList;
  const LanguageHoverWidget({super.key, required this.languageList});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Column(
                children: languageList.map((language) => InkWell(
                  onTap: () async {
                    if(languageProvider.languages.isNotEmpty && languageProvider.selectIndex != -1) {
                      Provider.of<LocalizationProvider>(context, listen: false).setLanguage(Locale(
                          language.languageCode!, language.countryCode));
                      Provider.of<ProductProvider>(context, listen: false).getLatestProductList(1);
                      Provider.of<CategoryProvider>(context, listen: false).getCategoryList(true);
                    }else {
                      showCustomSnackBar(getTranslated('select_a_language', context), context);
                    }},
                  child: TextHoverWidget(
                      builder: (isHover) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(color: isHover ? ColorResources.getGreyColor(context) : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                    child: Image.asset(language.imageUrl!, width: 25, height: 25),
                                  ),
                                  Text(language.languageName!, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: Dimensions.fontSizeSmall),),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                  ),
                )).toList(),
            ),
          );
        }
    );
  }
}
