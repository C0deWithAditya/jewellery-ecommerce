import 'package:hexacom_user/features/home/widgets/category_shimmer_widget.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_slider_list_widget.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:hexacom_user/common/widgets/text_hover_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesWebWidget extends StatefulWidget {
  const CategoriesWebWidget({Key? key}) : super(key: key);

  @override
  State<CategoriesWebWidget> createState() => _CategoriesWebWidgetState();
}

class _CategoriesWebWidgetState extends State<CategoriesWebWidget> {

  ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {

    return Consumer<CategoryProvider>(builder: (context,category,child){

      return category.categoryList != null? category.categoryList!.isNotEmpty ?
      SizedBox(
        height: 200,
        child: CustomSliderListWidget(
          controller: scrollController,
          verticalPosition: 50,
          horizontalPosition: 0,
          isShowForwardButton: category.categoryList != null && category.categoryList!.length > 5,
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            controller: scrollController,
            itemCount: category.categoryList?.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(top: 20, left: 10,right: 10),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  onTap: () => RouteHelper.getCategoryRoute(context, category.categoryList![index], action: RouteAction.push),
                  child: Column(children: [
                    OnHover(
                      child: Container(
                        height: 100, width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(Provider.of<ThemeProvider>(context).darkTheme ? 0.05 : 1),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow:Provider.of<ThemeProvider>(context).darkTheme ? null : [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 15, offset: const Offset(3,0))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: OnHover(
                            child: CustomImageWidget(
                                image: Provider.of<SplashProvider>(context, listen: false).baseUrls != null
                                    ? '${category.categoryList![index].image}':'',
                                width: 100, height: 100, fit: BoxFit.cover
                            ),
                          ),
                        ),
                      ),
                    ),

                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                        child:  SizedBox(
                          width: 120,
                          child: TextHoverWidget(
                            builder: (hovered) {
                              return Text(
                                category.categoryList![index].name!,
                                style: rubikRegular.copyWith(color: hovered ? Theme.of(context).primaryColor : null,fontSize: Dimensions.fontSizeDefault),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              );
                            }
                          ),
                        ),
                      ),
                    ),

                  ]),
                ),
              );
            },
          ),
        ),
      ) : Center(child: Text(getTranslated('no_category_available', context))) : const CategoryShimmerWidget();
    });
  }
}
