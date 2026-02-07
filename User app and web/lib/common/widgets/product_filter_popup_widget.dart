import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/text_hover_widget.dart';
import 'package:flutter/material.dart';

class ProductFilterPopupWidget extends StatelessWidget {
  final bool isFilterActive;
  final Function(ProductFilterType) onSelected;
  const ProductFilterPopupWidget({super.key, required this.isFilterActive, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProductFilterType>(
      padding: const EdgeInsets.all(0),
      onSelected: (ProductFilterType result) => onSelected(result),
      itemBuilder: (BuildContext c) => <PopupMenuEntry<ProductFilterType>>[
        PopupMenuItem<ProductFilterType>(
          value: ProductFilterType.highToLow,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextHoverWidget(
                  builder: (isHovered) {
                    return Text(getTranslated('high_to_low', context),style: rubikMedium.copyWith(
                      color: isHovered ? Theme.of(context).primaryColor : null,
                    ));
                  }
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            ],
          ),
        ),
        PopupMenuItem<ProductFilterType>(
          value: ProductFilterType.lowToHigh,
          child: TextHoverWidget(
              builder: (isHovered) {
                return Text(getTranslated('low_to_high', context), style: rubikMedium.copyWith(
                  color: isHovered ? Theme.of(context).primaryColor : null,
                ));
              }
          ),
        ),
      ],
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeLarge),
          ),

          if(isFilterActive) Positioned(
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
      ),
    );
  }
}
