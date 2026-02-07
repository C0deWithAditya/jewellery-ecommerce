import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AddressWidget extends StatelessWidget {

  final AddressModel addressModel;
  final int index;
  final bool fromSelectAddress;
  final bool? isAvailableForDelivery;
  const AddressWidget({
    super.key,
    required this.addressModel,
    required this.index,
    this.fromSelectAddress = false,
    this.isAvailableForDelivery
  });

  @override
  Widget build(BuildContext context) {
    final AddressProvider addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: () async {
          if(fromSelectAddress){
            if((configModel.googleMapStatus ?? false) && CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name){
              bool isAvailable = CheckOutHelper.isBranchAvailable(
                branches: configModel.branches ?? [],
                selectedBranch: configModel.branches![checkoutProvider.branchIndex],
                selectedAddress: addressProvider.addressList![index],
              );

              CheckOutHelper.selectDeliveryAddress(context,
                isAvailable: isAvailable, index: index, configModel: configModel,
                fromAddressList: true,
              );

            }else{
              CheckOutHelper.selectDeliveryAddress(context,
                isAvailable: true, index: index, configModel: configModel,
                fromAddressList: true,
              );
            }
          }

        },
        child: Stack(children: [

          Container(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              border: fromSelectAddress && index == addressProvider.selectAddressIndex ? Border.all(width: 1, color: Theme.of(context).primaryColor) : null,
              borderRadius: BorderRadius.circular(7),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 0.5, blurRadius: 0.5)
              ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Expanded(flex: 2, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                fromSelectAddress ? Radio(
                  activeColor: Theme.of(context).primaryColor,
                  value: index,
                  groupValue: addressProvider.selectAddressIndex,
                  onChanged: (_){},
                ) : Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 25),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                  Text(addressModel.addressType!, style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  )),

                  Text(addressModel.address!, maxLines: fromSelectAddress ? 1 : 3, style: rubikRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6), fontSize: Dimensions.fontSizeLarge,
                  )),
                ]))

              ])),

              if(!fromSelectAddress) PopupMenuButton<String>(
                padding: const EdgeInsets.all(0),
                onSelected: (String result) {
                  if (result == 'delete') {
                    ResponsiveHelper.showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                      title: getTranslated('remove_this_address', context),
                      subTitle: getTranslated('address_will_be_remove_from_list', context),
                      image: Images.locationDeleteIcon,
                      onPressRight: (){
                        Navigator.pop(context);

                        showDialog(context: context, barrierDismissible: false, builder: (context) => Center(
                          child: CustomLoaderWidget(color: Theme.of(context).primaryColor),
                        ));

                        addressProvider.deleteUserAddressByID(addressModel.id, index, (bool isSuccessful, String message) {
                          Navigator.pop(context);
                          showCustomSnackBar(message, context, isError: isSuccessful);
                        });
                      },

                    ));

                  } else {
                    addressProvider.setAddressStatusMessage = '';
                    RouteHelper.getAddAddressRoute(context, 'address', 'update', addressModel);
                  }
                },
                itemBuilder: (BuildContext c) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text(getTranslated('edit', context), style: rubikMedium),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(getTranslated('delete', context), style: rubikMedium),
                  ),
                ],
              ),

            ]),
          ),

          if(fromSelectAddress && !(isAvailableForDelivery ?? false))...[
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                child: Text(
                  getTranslated('out_of_coverage_for_this_branch', context),
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: rubikRegular.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),

            ),
          ],

        ]),
      ),
    );
  }
}
