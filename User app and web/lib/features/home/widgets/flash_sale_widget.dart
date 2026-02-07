import 'package:hexacom_user/features/flash_sale/widgets/flash_sale_timer_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/provider/localization_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Provider.of<LocalizationProvider>(context, listen: false).isLtr;
    return Consumer<FlashSaleProvider>(
      builder: (context, flashProvider, _) {
        return flashProvider.flashSaleModel?.products != null && flashProvider.flashSaleModel!.products!.isNotEmpty ? ResponsiveHelper.isDesktop(context) ? Row(children: [

          Container(
            height: 230, width: 350,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeDefault), bottomLeft: Radius.circular(Dimensions.paddingSizeDefault)),
              color: Theme.of(context).primaryColor.withOpacity(0.15),
              image: const DecorationImage(image: AssetImage(Images.flashSale), fit: BoxFit.cover),
            ),
            child: const FlashSaleTimerWidget(),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () => RouteHelper.getFlashSaleDetailsRoute(context, action: RouteAction.push),
                    child: Padding(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                      child: Text(getTranslated('view_all', context), style: rubikMedium),
                    ),
                  ),
                ),

                Container(
                  height: 195,
                  width: Dimensions.webScreenWidth,
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeDefault,
                  ),
                  child: SizedBox(
                    height: 170,
                    child: ListView.builder(
                      itemCount: flashProvider.flashSaleModel!.products!.length,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (ctx, index) => Container(
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        padding:  EdgeInsets.only(
                          left: index == 0 && isLtr ? Dimensions.paddingSizeDefault : 0,
                          right: index == 0 && !isLtr ? Dimensions.paddingSizeDefault : 0,
                        ),
                        width: 350, height: 170,
                        child: ProductCardWidget(
                          product: flashProvider.flashSaleModel!.products![index],
                          direction: Axis.horizontal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ]) : Column(children: [

          Stack(clipBehavior: Clip.none, children: [
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                color: Theme.of(context).primaryColor.withOpacity(0.15),
              ),
              child: FittedBox(
                alignment: Alignment.topCenter,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Image.asset(Images.flashSale, width: 150, height: 115, fit: BoxFit.cover),

                  const Padding(
                    padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge),
                    child: FlashSaleTimerWidget(),
                  ),

                ]),
              ),
            ),

            Positioned(
              bottom: 0, right: 0, left: 0,
              child: SizedBox(height: 170, child: ListView.builder(
                itemCount: flashProvider.flashSaleModel?.products?.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemBuilder: (ctx, index) => Container(
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  width: MediaQuery.of(context).size.width * 0.85, height: 170,
                  child: flashProvider.flashSaleModel == null ? const ProductShimmerWidget(isEnabled: true) : ProductCardWidget(
                    product: flashProvider.flashSaleModel!.products![index],
                    direction: Axis.horizontal,
                  ),
                ),
              )),
            ),
          ]),

          InkWell(
            onTap: () => RouteHelper.getFlashSaleDetailsRoute(context, action: RouteAction.push),
            child: Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              child: Text(getTranslated('view_all', context), style: rubikMedium),
            ),
          ),

        ]) : const SizedBox();
      }
    );
  }
}
