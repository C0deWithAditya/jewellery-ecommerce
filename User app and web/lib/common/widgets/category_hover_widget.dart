import 'package:go_router/go_router.dart';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/text_hover_widget.dart';
import 'package:flutter/material.dart';

class CategoryHoverWidget extends StatelessWidget {
  final List<CategoryModel>? categoryList;
  const CategoryHoverWidget({super.key, required this.categoryList});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding:  const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      child: Column(
          children: categoryList!.map((category) => InkWell(
            onTap: () async {
              RouteHelper.getCategoryRoute(context, category, action: RouteAction.push);
              context.pop();
              RouteHelper.getCategoryRoute(context, category, action: RouteAction.push);
            },
            child: TextHoverWidget(
                builder: (isHover) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(color: isHover ? ColorResources.getGreyColor(context) : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 200,child: Text(category.name!,maxLines: 1,overflow: TextOverflow.ellipsis,)),
                      ],
                    ),
                  );
                }
            ),
          )).toList()
      ),
    );
  }
}
