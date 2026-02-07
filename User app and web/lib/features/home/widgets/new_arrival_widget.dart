import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/custom_slider_list_widget.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:hexacom_user/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewArrivalWidget extends StatefulWidget {
  const NewArrivalWidget({Key? key}) : super(key: key);

  @override
  State<NewArrivalWidget> createState() => _NewArrivalWidgetState();
}

class _NewArrivalWidgetState extends State<NewArrivalWidget> {

  final ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    final bool isLtr = Provider.of<LocalizationProvider>(context, listen: false).isLtr;
    return Consumer<ProductProvider>(builder: (context, productProvider, child) {

      return productProvider.newArrivalProductsModel?.products != null && productProvider.newArrivalProductsModel!.products!.isNotEmpty ? CustomSliderListWidget(
        controller: scrollController,
        verticalPosition: 125,
        horizontalPosition: 0,
        isShowForwardButton: productProvider.newArrivalProductsModel != null && productProvider.newArrivalProductsModel!.products!.length > 3,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
            color: Theme.of(context).focusColor.withOpacity(0.15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 0,  // Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: TitleWidget(title: getTranslated('new_arrival', context), onTap: (){
                  RouteHelper.getSearchResultRoute(context, shortBy: SearchShortBy.newArrivals, action: RouteAction.push);
                }),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              SizedBox(
                height: 170,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  itemCount: productProvider.newArrivalProductsModel != null
                      ? productProvider.newArrivalProductsModel!.products!.length : 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) => productProvider.newArrivalProductsModel == null ? SizedBox(
                    width: ResponsiveHelper.isDesktop(context) ? 380 : MediaQuery.of(context).size.width * 0.85,
                    height: 170,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: ProductShimmerWidget(isEnabled: true),
                    ),
                  ) : Container(
                    padding: EdgeInsets.only(
                      left: isLtr && index == 0 ? Dimensions.paddingSizeSmall : 0,
                      right: isLtr && index == 0 ? 0 : Dimensions.paddingSizeSmall,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall).copyWith(
                      left: isLtr ? Dimensions.paddingSizeExtraSmall : 0,
                      right: isLtr ? 0 : Dimensions.paddingSizeExtraSmall,
                    ),
                    width: ResponsiveHelper.isDesktop(context) ? 360 : MediaQuery.of(context).size.width * 0.85,
                    height: 170,
                    child: ProductCardWidget(
                      product: productProvider.newArrivalProductsModel!.products![index],
                      direction: Axis.horizontal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),
            ]),
          ),
        ),
      ) : const SizedBox();
    });
  }
}
