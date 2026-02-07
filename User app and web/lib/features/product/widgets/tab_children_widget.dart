import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/product/widgets/product_review_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TabChildrenWidget extends StatefulWidget {
  const TabChildrenWidget({Key? key}) : super(key: key);

  @override
  State<TabChildrenWidget> createState() => _TabChildrenWidgetState();
}

class _TabChildrenWidgetState extends State<TabChildrenWidget> {
  bool showSeeMoreButton = true;

  @override
  Widget build(BuildContext context) {

    final ProductProvider productProvider = context.read<ProductProvider>();
    print("----------(PRODUCT PROVIDER)-----------${productProvider.product?.description}");

    return Consumer<ProductProvider>(builder: (context, productProvider, _){
      return productProvider.product == null ? const SizedBox() : productProvider.tabIndex == 0 ? (productProvider.product!.description == null || productProvider.product!.description!.isEmpty)
          ? Center(child: Text(getTranslated('no_description_found', context), style: rubikRegular.copyWith(
        fontSize: ResponsiveHelper.isDesktop(context) ? 20 : 16,
      ))) : Stack(children: [


        if(productProvider.product?.description?.isNotEmpty ?? false) Container(
          height: (productProvider.product != null && productProvider.product!.description != null && productProvider.product!.description!.length > 300) && showSeeMoreButton ? 100 : null,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          width: Dimensions.webScreenWidth,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: HtmlWidget(
              onTapUrl: (url)=> launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              productProvider.product!.description ?? '',
              textStyle: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ),
        ),


        if((productProvider.product!.description?.isNotEmpty ?? false) &&  productProvider.product!.description!.length > 300 && showSeeMoreButton) Positioned.fill(child: Align(
          alignment: Alignment.bottomCenter, child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            Theme.of(context).cardColor.withOpacity(0),
            Theme.of(context).cardColor,
          ])),
          width: Dimensions.webScreenWidth, height: 55,
        ),
        )),

        if((productProvider.product!.description?.isNotEmpty ?? false) && productProvider.product!.description!.length > 300 && showSeeMoreButton) Positioned.fill(child: Align(
          alignment: Alignment.bottomCenter, child: Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            height: 35, width: 100, child: CustomButtonWidget(
            backgroundColor: Theme.of(context).secondaryHeaderColor.withOpacity(0.7),
            style: rubikMedium.copyWith(color: Theme.of(context).textTheme.titleLarge?.color),
            btnTxt: getTranslated('see_more', context),
            onTap: (){
              setState(() {
                showSeeMoreButton = false;
              });
            })),
        )),

      ]) : const ProductReviewListWidget();
    });
  }
}
