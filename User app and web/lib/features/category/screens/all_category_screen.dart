import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/features/category/widgets/category_item_widget.dart';
import 'package:hexacom_user/features/category/widgets/sub_categories_shimmer_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllCategoryScreen extends StatefulWidget {
  const AllCategoryScreen({super.key});

  @override
  State<AllCategoryScreen> createState() => _AllCategoryScreenState();
}

class _AllCategoryScreenState extends State<AllCategoryScreen> {

  @override
  void initState() {
    super.initState();
    if(Provider.of<CategoryProvider>(context, listen: false).categoryList != null
        && Provider.of<CategoryProvider>(context, listen: false).categoryList!.isNotEmpty
    ) {
      _load();
    }else{
      Provider.of<CategoryProvider>(context, listen: false).getCategoryList(true).then((apiResponse) {
        if(apiResponse != null && apiResponse.response!.statusCode == 200 && apiResponse.response!.data != null){
          _load();
        }

      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('category', context)),
      body: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if(categoryProvider.categoryList == null){
            return  const Center(child: CircularProgressIndicator());
          }else if(categoryProvider.categoryList != null && categoryProvider.categoryList!.isEmpty){
            return const NoDataScreen();
          }else{

            return Row(children: [
              Container(
                width: ResponsiveHelper.isTab(context) ? 150 : 100,
                margin: const EdgeInsets.only(top: 9),
                height: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 3, blurRadius: 10)],
                ),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: categoryProvider.categoryList!.length,
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (context, index) {

                    CategoryModel category = categoryProvider.categoryList![index];
                    return InkWell(
                      onTap: () {
                        categoryProvider.changeIndex(index);
                        categoryProvider.getSubCategoryList(category.id!);
                      },
                      child: CategoryItemWidget(
                        title: category.name,
                        icon: category.image,
                        isSelected: categoryProvider.categoryIndex == index,
                      ),
                    );

                  },
                ),
              ),

              categoryProvider.subCategoryList != null ? Expanded(
                child: ListView.builder(
                  padding:  const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  itemCount: categoryProvider.subCategoryList!.length + 1,
                  itemBuilder: (context, index) {

                    return ListTile(
                      onTap: () {
                        categoryProvider.changeSelectedIndex(-1);

                        if(index == 0) {
                          RouteHelper.getCategoryRoute(context, categoryProvider.categoryList![categoryProvider.categoryIndex], action: RouteAction.push);
                        }else{
                          RouteHelper.getCategoryRoute(context,
                            categoryProvider.categoryList![categoryProvider.categoryIndex],
                            subCategoryId: categoryProvider.subCategoryList![index-1].id,
                            action: RouteAction.push
                          );
                        }
                      },
                      tileColor: index == 0 ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      title: Text(index == 0
                          ? '${categoryProvider.categoryList![categoryProvider.categoryIndex].totalProductQuantity}+ ${getTranslated('products', context)}' : categoryProvider.subCategoryList![index-1].name!,
                        style: rubikMedium.copyWith(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                    );
                  },
                ),
              )
                  : const Expanded(child: SubCategoriesShimmerWidget()),
            ]);
          }
        },
      ))),
    );
  }

  _load() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.changeIndex(0, notify: false);
    if(categoryProvider.categoryList!.isNotEmpty && categoryProvider.categoryList![0].id != null) {
      categoryProvider.getSubCategoryList(categoryProvider.categoryList![0].id!);
    }

  }
}


