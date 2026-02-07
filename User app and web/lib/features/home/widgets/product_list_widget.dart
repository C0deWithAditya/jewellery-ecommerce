import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/paginated_list_view.dart';
import 'package:hexacom_user/common/widgets/product_card_widget.dart';
import 'package:hexacom_user/common/widgets/product_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';


class ProductListWidget extends StatelessWidget {
  final ProductFilterType? filterType;
  final ScrollController? scrollController;
  const ProductListWidget({Key? key, this.scrollController, this.filterType}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {

        return PaginatedListView(
          scrollController: scrollController!,
          totalSize: productProvider.latestProductModel?.totalSize,
          offset: productProvider.latestProductModel?.offset,
          limit: productProvider.latestProductModel?.limit,
          onPaginate: (int? offset)=> productProvider.getLatestProductList(
            offset!,limit: productProvider.latestProductModel?.limit,
            filterType: filterType, isUpdate: true,
          ),
          itemView: productProvider.latestProductModel != null ? productProvider.latestProductModel!.products!.isNotEmpty ?

          ResponsiveHelper.isDesktop(context) ? GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 4,
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1),
            itemCount: productProvider.latestProductModel?.products?.length,
            itemBuilder: (BuildContext context, int index) {
              return ProductCardWidget(product: productProvider.latestProductModel!.products![index]);
            },
          ) : StaggeredGrid.count(
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: productProvider.latestProductModel!.products!.map((product) => StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProductCardWidget(product: product),
                ),
              )).toList()): const NoDataScreen(

          ) : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
              childAspectRatio: (1/1.4),
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : 2,
            ),
            itemCount: 12,
            itemBuilder: (BuildContext context, int index) {
              return ProductShimmerWidget(isEnabled: productProvider.latestProductModel == null, isWeb: true);
            },
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          ),
        );
      },
    );
  }
}
