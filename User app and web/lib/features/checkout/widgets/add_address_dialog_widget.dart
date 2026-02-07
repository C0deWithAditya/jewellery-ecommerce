import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/features/address/widgets/address_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddAddressDialogWidget extends StatelessWidget {
  const AddAddressDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final  CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);

    return Dialog(child: Consumer<AddressProvider>(
      builder: (context, locationProvider, _) {
        bool isNotEmptyAddress = (locationProvider.addressList != null && locationProvider.addressList!.isNotEmpty);

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          width: (Dimensions.webScreenWidth / 2),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                onPressed: ()=> Navigator.pop(context),
                icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
              ),
            ]),

            Text(getTranslated(isNotEmptyAddress ? 'select_form_saved_address' : 'you_have_to_save_address' , context),
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),



            if(!isNotEmptyAddress) Image.asset(Images.locationBannerImage, height: 120, width: 120),

            if(!isNotEmptyAddress) Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeExtraSmall),
              child: Text(
                getTranslated('you_dont_have_any_saved_address_yet', context),
                style: rubikRegular,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Flexible(child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                locationProvider.addressList != null ? locationProvider.addressList!.isNotEmpty ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  itemCount: locationProvider.addressList?.length,
                  itemBuilder: (context, index) {

                    bool isDistanceWiseDelivery = CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.distance.name;
                    AddressModel? addressModel = locationProvider.addressList?[index];

                    bool isAddressAvailableForDelivery = true;

                    if(isDistanceWiseDelivery && (addressModel?.latitude == null && addressModel?.longitude == null)){
                      isAddressAvailableForDelivery = false;
                    }

                    return Center(child: SizedBox(width: 700, child: AddressWidget(
                      fromSelectAddress: true,
                      addressModel: locationProvider.addressList![index],
                      index: index,
                      isAvailableForDelivery: isAddressAvailableForDelivery,
                    )));
                  },
                ) : const SizedBox() : const Center(child: CircularProgressIndicator()),

              ]),
            )),

            // if(!isNotEmptyAddress) const CurrentLocationButton(isBorder: true),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                RouteHelper.getAddAddressRoute(context, 'checkout', 'add', AddressModel(), routeAction: RouteAction.push);
                await locationProvider.initAddressList();

                CheckOutHelper.selectDeliveryAddressAuto(
                  isLoggedIn: true,
                  orderType: checkoutProvider.getCheckOutData?.orderType,
                  lastAddress: null,
                );

              },
              icon: Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor),
              label: Text(getTranslated('add_new_address', context), style: rubikMedium.copyWith()),
            ),

           isNotEmptyAddress? Padding(
             padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
             child: CustomButtonWidget(
                btnTxt: getTranslated('select', context), onTap: ()=>  Navigator.pop(context),
              ),
           ) : const SizedBox(height: Dimensions.paddingSizeDefault),

          ]),
        );
      }
    ));
  }
}

class CurrentLocationButton extends StatelessWidget {
  final bool isBorder;
  const CurrentLocationButton({
    Key? key, required this.isBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: (){
        Navigator.pop(context);
        RouteHelper.getAddAddressRoute(context, 'checkout', 'add', AddressModel(), routeAction: RouteAction.push);
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault))),
        fixedSize: const Size(200, 40),
        backgroundColor: isBorder ?  Theme.of(context).primaryColor : Theme.of(context).cardColor,
      ),
      icon:  Icon(
        Icons.my_location,
        color: isBorder ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
      ),
      label: Text(getTranslated('use_my_current_location', context), style:  rubikRegular.copyWith(
        fontSize: Dimensions.fontSizeExtraSmall,
        color: isBorder ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
      )),

    );
  }
}
