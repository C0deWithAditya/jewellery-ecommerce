import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentButtonWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final Function onTap;

  const PaymentButtonWidget({
    Key? key, required this.isSelected, required this.icon,
    required this.title, required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (ctx, orderController, _) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: InkWell(
          onTap: onTap as void Function()?,
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                  border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.1))
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
              child: Row(children: [
                Image.asset(
                  icon, width: 20, height: 20,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Text(title, style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                ))),
              ]),

            ),

            if(isSelected) Positioned(top: -7, right: -7, child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            )),
          ]),
        ),
      );
    });
  }
}
