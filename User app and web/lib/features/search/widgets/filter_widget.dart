import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/features/search/widgets/short_button_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';

class FilterWidget extends StatefulWidget {
  final String? query;
  const FilterWidget({Key? key, required this.query}) : super(key: key);

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  @override
  void initState() {
    Provider.of<SearchProvider>(context, listen: false).setLowerAndUpperValue(null, null, isUpdate: false);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final List<CategoryModel> categoryList = Provider.of<CategoryProvider>(context, listen: false).categoryList ?? [];

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          final isNotEqualValue = (searchProvider.lowerValue ?? (searchProvider.searchProductModel?.minPrice ?? 0)) > (searchProvider.upperValue ?? (searchProvider.searchProductModel?.maxPrice ?? 0)) ;


          return SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),

                  Text(
                    getTranslated('filter', context),
                    textAlign: TextAlign.center,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: ColorResources.getGreyBunkerColor(context),
                    ),
                  ),


                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 25, color: Theme.of(context).disabledColor),
                  ),

                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                getTranslated('price', context),
                style: rubikRegular,
              ),

              FlutterSlider(
                values: [searchProvider.lowerValue ?? (searchProvider.searchProductModel?.minPrice ?? 0),  (searchProvider.upperValue ?? (searchProvider.searchProductModel?.maxPrice ?? 0) + (isNotEqualValue ? 0 : 1))],
                rangeSlider: true,
                max: (searchProvider.searchProductModel?.maxPrice ?? 0) + (isNotEqualValue ? 0 : 1),
                min: searchProvider.searchProductModel?.minPrice ?? 0,
                handlerHeight: 25,
                handlerWidth: 25,
                trackBar: FlutterSliderTrackBar(activeTrackBar: BoxDecoration(color: Theme.of(context).primaryColor), activeTrackBarHeight: 6),
                handler: FlutterSliderHandler(decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle), child: const SizedBox()),
                rightHandler: FlutterSliderHandler(decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle), child: const SizedBox()),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  searchProvider.setLowerAndUpperValue(lowerValue, upperValue);
                },
              ),

              Text(
                getTranslated('ratings', context),
                style: rubikRegular,
              ),

              Center(
                child: SizedBox(
                  height: 30,
                  child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: Icon(
                          searchProvider.rating < (index + 1) ? Icons.star_border_rounded : Icons.star_rounded,
                          size: 25,
                          color: searchProvider.rating < (index + 1) ? ColorResources.getGreyColor(context) : Theme.of(context).primaryColor,
                        ),
                        onTap: () => searchProvider.setRating(index + 1),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // sort by
              Text(getTranslated('sort_by', context), style: rubikRegular),
              const SizedBox(height: 15),

              Row(children: [

                SortButtonWidget(
                  onTap: (){
                    if(searchProvider.selectedSearchShotBy != SearchShortBy.newArrivals) {
                      searchProvider.setSelectShortBy(SearchShortBy.newArrivals);
                    }
                  },
                  isSelected: searchProvider.selectedSearchShotBy == SearchShortBy.newArrivals,
                  name: getTranslated('new_arrival', context),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                SortButtonWidget(
                  onTap: (){
                    if(searchProvider.selectedSearchShotBy != SearchShortBy.offerProducts) {
                      searchProvider.setSelectShortBy(SearchShortBy.offerProducts);
                    }
                  },
                  isSelected: searchProvider.selectedSearchShotBy == SearchShortBy.offerProducts,
                  name: getTranslated('offer_product', context),
                ),

              ],),
              const SizedBox(height: 15),

              Text(
                getTranslated('category', context),
                style: rubikRegular,
              ),
              const SizedBox(height: 13),

              Wrap(
                children: categoryList.map((categoryData) {
                  return SortButtonWidget(
                    onTap: () {
                      searchProvider.selectCategoryListAdd(categoryData.id!);
                    },
                    isSelected: searchProvider.selectCategoryList.contains(categoryData.id!),
                    name: categoryData.name!,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(1, ResponsiveHelper.isDesktop(context) ? 45 : 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50), side: BorderSide(width: 2, color: Theme.of(context).disabledColor.withOpacity(0.1))),
                  ),
                  onPressed: () {
                    searchProvider.resetSearchFilterData(isUpdate: true);
                    searchProvider.setSelectShortBy(null, isUpdate: true);
                    },
                  child: Text(getTranslated('reset', context), style: rubikRegular.copyWith(
                    color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge,
                  )),
                )),

                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomButtonWidget(
                    height: ResponsiveHelper.isDesktop(context) ? 45 : 40,
                    btnTxt: getTranslated('apply', context),
                    onTap: () {
                      searchProvider.searchProduct(
                        offset: 1,
                        query: widget.query ?? '',
                        rating: searchProvider.rating == -1 ? null : searchProvider.rating,
                        priceLow: searchProvider.lowerValue,
                        priceHigh: searchProvider.upperValue,
                        categoryIds: searchProvider.selectCategoryList,
                        shortBy: searchProvider.selectedSearchShotBy,
                        isUpdate: true,

                      );
                      Navigator.pop(context);

                    },
                  ),
                ),
              ]),
            ],
          ));
        }),
    );
  }
}

