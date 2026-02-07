import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/add_address_dialog_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_shadow_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class DeliveryAddressWidget extends StatelessWidget {
  final bool selfPickup;

  const DeliveryAddressWidget({
    super.key, required this.selfPickup,
  });

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return !selfPickup ? CustomShadowWidget(
      margin:  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      child: Consumer<AddressProvider>(
        builder: (context, locationProvider, _) => Consumer<CheckoutProvider>(
            builder: (context, checkoutProvider, _) {
              bool isAvailable = false;

              AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
                addressList: locationProvider.addressList,
                selectedAddress: checkoutProvider.orderAddressIndex == -1 ? null : locationProvider.addressList?[checkoutProvider.orderAddressIndex],
                lastOrderAddress: null,
              );

              if(deliveryAddress != null &&
                  (configModel.googleMapStatus ?? false) &&
                  CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name
                  && ((deliveryAddress.latitude != null && deliveryAddress.latitude!.isNotEmpty) && (deliveryAddress.longitude != null && deliveryAddress.longitude!.isNotEmpty))
              ) {
                isAvailable = CheckOutHelper.isBranchAvailable(
                  branches: configModel.branches ?? [],
                  selectedBranch: configModel.branches![checkoutProvider.branchIndex],
                  selectedAddress: deliveryAddress,
                );

                if(!isAvailable) {
                  deliveryAddress = null;
                }
              }

              return locationProvider.addressList == null ? const DeliverySectionShimmer() :  Padding(
                padding:  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text('${getTranslated('delivery_to', context)} -', style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const Expanded(child: SizedBox()),
                    TextButton(
                      onPressed: ()=> showDialog(context: context, builder: (_)=> const AddAddressDialogWidget()),
                      child: Text(getTranslated(deliveryAddress == null || checkoutProvider.orderAddressIndex == -1  ? 'add' : 'change', context), style: rubikMedium.copyWith(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      )),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  deliveryAddress == null || checkoutProvider.orderAddressIndex == -1 ? Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Text(getTranslated('no_contact_info_added', context), style: rubikRegular.copyWith(color: Theme.of(context).colorScheme.error)),
                    ]),
                  ) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    ResponsiveHelper.isDesktop(context) ? Row(children: [
                      _ContactItemWidget(icon: Icons.home, title: getTranslated(deliveryAddress.addressType, context)),
                      const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                      _ContactItemWidget(icon: Icons.person, title: deliveryAddress.contactPersonName ?? ''),
                      const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                      _ContactItemWidget(icon: Icons.call, title: deliveryAddress.contactPersonNumber ?? ''),
                    ]) : Column(children: [
                      _ContactItemWidget(icon: Icons.home, title: getTranslated(deliveryAddress.addressType, context)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      _ContactItemWidget(icon: Icons.person, title: deliveryAddress.contactPersonName ?? ''),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      _ContactItemWidget(icon: Icons.call, title: deliveryAddress.contactPersonNumber ?? ''),
                    ]),


                    const Divider(height: Dimensions.paddingSizeDefault),

                    Text(deliveryAddress.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                      if(deliveryAddress.houseNumber != null) Expanded(
                        child: Text(
                          '${getTranslated('house', context)} - ${deliveryAddress.houseNumber}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      if(deliveryAddress.floorNumber != null) Expanded(
                        child: Text(
                          '${getTranslated('floor', context)} - ${deliveryAddress.floorNumber}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),


                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ]),

                ]),
              );
            }),
      ),
    ) : const SizedBox();
  }
}

class _ContactItemWidget extends StatelessWidget {
  final IconData icon;
  final String? title;
  const _ContactItemWidget({
    Key? key,
    required this.icon, this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.5)),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Text(title ?? ''),
    ]);
  }
}


class DeliverySectionShimmer extends StatelessWidget {
  const DeliverySectionShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(child: Column(children: [
      Container(
        margin:  const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
        child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(height: 14, width: 200, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
            Container(height: 14, width: 50, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
          ]),

          const Divider(height: Dimensions.paddingSizeDefault),

          Column(
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: Dimensions.paddingSizeLarge),

                Container(height: 14, width: 200, decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2),
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: Dimensions.paddingSizeLarge),

                Container(height: 14, width: 250, decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2),
                )),
              ]),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),



        ]),
      ),


    ]));
  }
}
