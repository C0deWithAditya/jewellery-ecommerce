import 'package:hexacom_user/features/category/providers/category_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SortButtonWidget extends StatelessWidget {
  final bool isSelected;
  final String name;
  final Function onTap;
  const SortButtonWidget({Key? key, required this.isSelected, required this.name, required this.onTap }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: ()=> onTap(),
      child: Consumer<CategoryProvider>(
          builder: (context, category, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.transparent : Theme.of(context).disabledColor.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(10),
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: isSelected ? Colors.white : Theme.of(context).hintColor),
              ),
            );
          }
      ),
    );
  }
}
