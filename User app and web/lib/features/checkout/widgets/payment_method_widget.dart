import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentMethodWidget extends StatelessWidget {
  final Function(int index) onTap;

  final List<PaymentMethod> paymentList;
  const PaymentMethodWidget({
    Key? key, required this.onTap, required this.paymentList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);



    return SingleChildScrollView(child: ListView.builder(
      itemCount: paymentList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index){
        bool isSelected = paymentList[index] == checkoutProvider.paymentMethod;

        return InkWell(
          onTap: ()=> onTap(index),
          child: Container(
            decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).disabledColor)
                  ),
                  child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                CustomImageWidget(
                  height: Dimensions.paddingSizeLarge, fit: BoxFit.contain,
                  image: '${splashProvider.configModel?.baseUrls?.getWayImageUrl}/${paymentList[index].getWayImage}',
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(
                  paymentList[index].getWayTitle ?? '',
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ]),


            ]),
          ),
        );
      },));
  }
}
