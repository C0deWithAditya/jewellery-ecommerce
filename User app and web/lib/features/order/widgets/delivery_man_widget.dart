import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/rating_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeliveryManWidget extends StatelessWidget {
  final DeliveryMan? deliveryMan;
  const DeliveryManWidget({Key? key, required this.deliveryMan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          color: Theme.of(context).shadowColor,
          blurRadius: 5, spreadRadius: 1,
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getTranslated('delivery_man', context), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
        ListTile(
          leading: ClipOval(
            child: FadeInImage.assetNetwork(
              placeholder: Images.placeholder(context),
              image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.deliveryManImageUrl}/${deliveryMan!.image}',
              height: 40, width: 40, fit: BoxFit.cover,
              imageErrorBuilder: (a,c,g) => Image.asset(Images.placeholder(context),height: 40, width: 40, fit: BoxFit.cover),
            ),
          ),
          title: Text(
            '${deliveryMan!.fName} ${deliveryMan!.lName}',
            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          subtitle: RatingBarWidget(rating: deliveryMan!.rating!.isNotEmpty ? double.parse(deliveryMan!.rating![0].average!) : 0, size: 15),
          trailing: InkWell(
            onTap: () => launchUrlString('tel:${deliveryMan!.phone}', mode: LaunchMode.externalApplication),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(shape: BoxShape.circle, color: ColorResources.getSearchBg(context)),
              child: const Icon(Icons.call_outlined),
            ),
          ),
        ),
      ]),
    );
  }
}
