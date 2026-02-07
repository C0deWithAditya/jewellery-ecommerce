import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_slider_list_widget.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfferProductWidget extends StatefulWidget {
  const OfferProductWidget({super.key});

  @override
  State<OfferProductWidget> createState() => _OfferProductWidgetState();
}

class _OfferProductWidgetState extends State<OfferProductWidget> {
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    // scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, offerProduct, child) {

        return ResponsiveHelper.isDesktop(context) ? CustomSliderListWidget(
          controller: scrollController,
          verticalPosition: 270,
          horizontalPosition: 0,
          isShowForwardButton: offerProduct.offerProductList != null && offerProduct.offerProductList!.length > 5,
          child: Container(
            height: 410,
            margin: const EdgeInsets.only(top: 30, bottom: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              image: const DecorationImage(
                image: AssetImage(Images.offerProductBg),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(children: [

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  const SizedBox(),

                  Text(getTranslated('offer_product', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge)),

                  InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () => RouteHelper.getSearchResultRoute(context, shortBy: SearchShortBy.offerProducts, action: RouteAction.push),
                    child: Padding(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                      child: Text(getTranslated('view_all', context), style: rubikMedium),
                    ),
                  ),

                ]),
              ),

              Expanded(
                child: Consumer<ProductProvider>(
                    builder: (context, offerProduct, child) {
                      return offerProduct.offerProductList == null ? const SizedBox() : offerProduct.offerProductList!.isEmpty ? const SizedBox() : SizedBox(
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          controller: scrollController,
                          itemCount: offerProduct.offerProductList!.length,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                          itemBuilder: (ctx, index) => Container(
                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                            width: 210,
                            child: ProductCardWidget(
                              product: offerProduct.offerProductList![index],
                            ),
                          ),
                        ),
                      );
                    }
                ),
              ),

            ]),
          ),
        ) : Column(children: [

          Stack(clipBehavior: Clip.none, children: [
            Container(
              height: 300,
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: 80),
              padding: const EdgeInsets.only(left: 20, top: 17, right: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                image: const DecorationImage(
                  image: AssetImage(Images.offerProductBg),
                  fit: BoxFit.cover,
                ),
              ),
              child: TitleWidget(
                title: getTranslated('offer_product', context),
                onTap: () => RouteHelper.getSearchResultRoute(context, shortBy: SearchShortBy.offerProducts, action: RouteAction.push),
              ),
            ),

            Positioned(
              right: 0, left: 0, top: 70,
              child: SizedBox(
                height: 320,
                child: Consumer<ProductProvider>(
                    builder: (context, offerProduct, child) {
                      return offerProduct.offerProductList == null ? const SizedBox() :  ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: offerProduct.offerProductList != null && offerProduct.offerProductList!.length > 5 ? 5 : offerProduct.offerProductList?.length,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        itemBuilder: (ctx, index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          width: MediaQuery.of(context).size.width * 0.55, height: 320,
                          child: ProductCardWidget(
                            product: offerProduct.offerProductList![index],
                          ),
                        ),
                      );
                    }
                ),
              ),
            ),
          ]),

        ]);
      }
    );
  }
}
