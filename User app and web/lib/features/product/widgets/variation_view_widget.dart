import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VariationViewWidget extends StatelessWidget {
  const VariationViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: productProvider.product!.choiceOptions!.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text(productProvider.product!.choiceOptions![index].title!, style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              CustomSingleChildListWidget(
                scrollDirection: Axis.horizontal,
                itemCount: productProvider.product!.choiceOptions![index].options!.length,
                itemBuilder: (i) {
                  return Container(
                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => productProvider.setCartVariationIndex(index, i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 8),
                        decoration: BoxDecoration(
                          color: productProvider.variationIndex![index] != i ? Theme.of(context).dividerColor.withOpacity(0.3) : Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Icon(
                              productProvider.variationIndex![index] != i ? Icons.radio_button_unchecked : Icons.radio_button_checked,
                              color: productProvider.variationIndex![index] != i ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Text(
                              productProvider.product!.choiceOptions![index].options![i].trim(), maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: rubikRegular.copyWith(
                                color: productProvider.variationIndex![index] != i ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: index != productProvider.product!.choiceOptions!.length-1 ? Dimensions.paddingSizeLarge : 0),
            ]);
          },
        );
      }
    );
  }
}
