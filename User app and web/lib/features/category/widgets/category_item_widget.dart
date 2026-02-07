import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';

class CategoryItemWidget extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;

  const CategoryItemWidget({Key? key, required this.title, required this.icon, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 110,
      decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor
      ),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            //padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.1)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: FadeInImage.assetNetwork(
                placeholder: Images.placeholder(context),
                image: '$icon',
                fit: BoxFit.cover, width: 100, height: 100,
                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            child: Text(title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: rubikRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: isSelected ? Theme.of(context).canvasColor : Theme.of(context).textTheme.bodyLarge?.color
                )),
          ),
        ]),
      ),
    );
  }
}
