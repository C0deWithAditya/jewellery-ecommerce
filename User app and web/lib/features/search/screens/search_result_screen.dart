import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/paginated_list_view.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:hexacom_user/features/search/widgets/filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchString;
  final SearchShortBy? shortBy;
  const SearchResultScreen({Key? key, required this.searchString, this.shortBy}) : super(key: key);

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final SearchProvider searchProvider = Provider.of<SearchProvider>(context, listen: false);

    searchProvider.resetSearchFilterData(isUpdate: false);

    bool isFirst = true;


    searchProvider.setSelectShortBy(null, isUpdate: false);
    if(widget.shortBy != null) {
      searchProvider.setSelectShortBy(widget.shortBy, isUpdate: false);
    }

    if (isFirst) {
      _searchController.text = widget.searchString;
      isFirst = false;
    }

    searchProvider.searchProduct(offset: 1, query: widget.searchString, shortBy: widget.shortBy);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context, listen: false).darkTheme;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const CustomAppBarWidget(onlyDesktop: true) : null,
      body: SafeArea(
        child: Consumer<SearchProvider>(
          builder: (context, searchProvider, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(!ResponsiveHelper.isDesktop(context)) Center(child: Container(
                width: Dimensions.webScreenWidth,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 30,
                    )]
                ),
                child: Row(
                  children: [
                    ResponsiveHelper.isDesktop(context) ? const SizedBox(): Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.2), width: 1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CustomTextFieldWidget(
                            fillColor: Theme.of(context).primaryColor.withOpacity(0.04),
                            hintText: getTranslated('search_items_here', context),
                            controller: _searchController,
                            isShowPrefixIcon: true,
                            prefixAssetUrl: Images.search,
                            inputAction: TextInputAction.search,
                            prefixAssetImageColor: Theme.of(context).primaryColor,
                            isIcon: true,
                            onSubmit: ()=> searchProvider.searchProduct(offset: 1, query: _searchController.text),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    ResponsiveHelper.isDesktop(context) ?
                    const SizedBox():IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 25),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webScreenWidth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${searchProvider.searchProductModel?.products?.length ?? '0'} ${getTranslated('product_found', context)}',
                              style: rubikRegular.copyWith(color: ColorResources.getGreyBunkerColor(context)),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                      child: SizedBox(width: 550, child: FilterWidget(
                                          query: _searchController.text,
                                        )),
                                    );

                                  });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                    border: Border.all(color: isDark ? Colors.white : Theme.of(context).primaryColor),
                                  ),
                                  child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor, size: 20),
                                ),

                              if(searchProvider.selectedSearchShotBy != null)  Positioned(
                                  top: 8, right: 7,
                                  child: Container(
                                    height: 10, width: 10,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                ),
                              ],
                            )
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),

              Expanded(
                child: searchProvider.searchProductModel != null && searchProvider.searchProductModel!.products!.isEmpty ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                        child: NoDataScreen(title: getTranslated('no_product_found', context)),
                      ),

                      const FooterWebWidget(footerType: FooterType.nonSliver),

                    ],
                  ),
                ) : SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                              child: SizedBox(
                                width: Dimensions.webScreenWidth,
                                child: PaginatedListView(
                                  scrollController: scrollController,
                                  totalSize: searchProvider.searchProductModel?.totalSize,
                                  offset: searchProvider.searchProductModel?.offset,
                                  onPaginate: (int? offset)=> searchProvider.searchProduct(
                                    offset: offset!, query: _searchController.text, isUpdate: true,
                                    shortBy: widget.shortBy,
                                  ),
                                  itemView: ResponsiveHelper.isDesktop(context) || searchProvider.searchProductModel == null ? GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                                      childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 0.7,
                                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5  : 2 ,
                                    ),
                                    itemCount: searchProvider.searchProductModel == null ? 10 : searchProvider.searchProductModel!.products!.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                    itemBuilder: (context, index) {
                                      return searchProvider.searchProductModel == null
                                          ? const ProductShimmerWidget(isEnabled: true, isWeb: true)
                                          : ProductCardWidget(product: searchProvider.searchProductModel!.products![index]);
                                    },
                                  ) : StaggeredGrid.count(
                                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : 2,
                                      mainAxisSpacing: 4, crossAxisSpacing: 4,
                                      children: searchProvider.searchProductModel!.products!.map((product) => StaggeredGridTile.fit(
                                        crossAxisCellCount: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ProductCardWidget(product: product),
                                        ),
                                      )).toList()),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          const FooterWebWidget(footerType: FooterType.nonSliver),

                        ],
                      ),
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
