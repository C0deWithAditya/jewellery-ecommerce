import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/home_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/paginated_list_view.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_filter_popup_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:hexacom_user/common/widgets/title_widget.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/features/flash_sale/widgets/flash_sale_timer_widget.dart';
import 'package:hexacom_user/features/menu/widgets/options_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class FlashSaleDetailsScreen extends StatefulWidget {
  const FlashSaleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<FlashSaleDetailsScreen> createState() => _FlashSaleDetailsScreenState();
}

class _FlashSaleDetailsScreenState extends State<FlashSaleDetailsScreen> {
  final GlobalKey<ScaffoldState> drawerGlobalKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  ProductFilterType? filterType;



  @override
  void initState() {
    super.initState();
    final FlashSaleProvider flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);

    flashSaleProvider.getFlashSaleProducts(1, false);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: drawerGlobalKey,
      endDrawerEnableOpenDragGesture: false,
      drawer: ResponsiveHelper.isTab(context) ? const Drawer(child: OptionsWidget(onTap: null)) : const SizedBox(),
      appBar: CustomAppBarWidget(
        title: getTranslated('flash_sale', context),
        onlyDesktop: true,
      ),
      body: CustomScrollView(controller: _scrollController, slivers: [
        if(!ResponsiveHelper.isDesktop(context)) HomeAppBarWidget(drawerGlobalKey: drawerGlobalKey),

        SliverToBoxAdapter(child: Column(children: [

          Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Consumer<FlashSaleProvider>(builder: (context, flashSaleProvider, child) {
              return Column(children: [

                Container(
                  height: ResponsiveHelper.isDesktop(context) ? 200 : 100,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [

                    Image.asset(Images.flashSale, width: ResponsiveHelper.isDesktop(context) ? 250 : 110, height: ResponsiveHelper.isDesktop(context) ? 200 : 100, fit: BoxFit.cover),

                    const Padding(
                      padding: EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                      child: FlashSaleTimerWidget(),
                    ),

                  ]),
                ),
                const SizedBox(height: 30),

                TitleWidget(
                  title: getTranslated('all_items', context),
                  leadingButton: ProductFilterPopupWidget(
                    isFilterActive: filterType != null,
                    onSelected: (result){
                      filterType = result;
                      flashSaleProvider.getFlashSaleProducts(1, true, filterType: result);
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                PaginatedListView(
                  scrollController: _scrollController,
                  totalSize: flashSaleProvider.flashSaleModel?.totalSize,
                  offset: flashSaleProvider.flashSaleModel?.offset,
                  onPaginate: (int? offset) async => await flashSaleProvider.getFlashSaleProducts(offset!, false),
                  itemView: flashSaleProvider.flashSaleModel != null ? flashSaleProvider.flashSaleModel!.products!.isNotEmpty ?

                  ResponsiveHelper.isDesktop(context) ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                      childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.45) : 4,
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1,
                    ),
                    itemCount: flashSaleProvider.flashSaleModel!.products?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return ProductCardWidget(product: flashSaleProvider.flashSaleModel!.products![index]);
                    },
                  ) : StaggeredGrid.count(
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : 2,
                    mainAxisSpacing: 15, crossAxisSpacing: 15,
                    children: flashSaleProvider.flashSaleModel!.products!.map((product) => StaggeredGridTile.fit(
                      crossAxisCellCount: 1,
                      child: ProductCardWidget(product: product),
                    )).toList(),
                  ) : const NoDataScreen() : GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                      childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 4,
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 2 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    itemCount: 12,
                    itemBuilder: (BuildContext context, int index) {
                      return ProductShimmerWidget(isEnabled: flashSaleProvider.flashSaleModel == null, isWeb: ResponsiveHelper.isDesktop(context));
                    },
                  ),
                ),




              ]);
            }
            ),
          ))),

          const FooterWebWidget(footerType: FooterType.nonSliver),

        ])),
      ]),
    );
  }
}
