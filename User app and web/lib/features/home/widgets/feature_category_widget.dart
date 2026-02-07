import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/models/feature_category_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/custom_shadow_widget.dart';
import 'package:hexacom_user/common/widgets/custom_slider_list_widget.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeatureCategoryWidget extends StatefulWidget {
  final FeaturedCategory? featuredCategory;
  const FeatureCategoryWidget({Key? key, required this.featuredCategory}) : super(key: key);

  @override
  State<FeatureCategoryWidget> createState() => _FeatureCategoryWidgetState();
}

class _FeatureCategoryWidgetState extends State<FeatureCategoryWidget> {

  final ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return widget.featuredCategory == null ? const SizedBox() : CustomShadowWidget(
      margin: const EdgeInsets.symmetric( vertical: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Column(children: [

        TitleWidget(
          title: widget.featuredCategory?.category?.name ?? '',
          onTap: () => RouteHelper.getCategoryRoute(context,
            CategoryModel(id: widget.featuredCategory?.category?.id,
              banner: widget.featuredCategory?.category?.banner,
              name: widget.featuredCategory?.category?.name,
              image: widget.featuredCategory?.category?.image,
            ),
            action: RouteAction.push
          )
        ),
        const SizedBox(height: 20),

        Consumer<ProductProvider>(
          builder: (context, f, child) {

            return CustomSliderListWidget(
              controller: scrollController,
              verticalPosition: 125,
              isShowForwardButton: (widget.featuredCategory?.products?.length ?? 0) > 5,
              child: SizedBox(height: 320, child: ListView.builder(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                itemCount: widget.featuredCategory?.products?.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                itemBuilder: (ctx, index) => widget.featuredCategory!.products![index].status! ? Container(
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  width: ResponsiveHelper.isDesktop(context) ? 210 : MediaQuery.of(context).size.width * 0.55,
                  height: 320,
                  child: ProductCardWidget(
                    product: widget.featuredCategory!.products![index],
                  ),
                ) : const SizedBox(),
              )),
            );
          }
        ),

      ]),
    );
  }
}
