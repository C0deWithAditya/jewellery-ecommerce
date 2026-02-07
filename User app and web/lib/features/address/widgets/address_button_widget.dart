import 'package:go_router/go_router.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class AddressButtonWidget extends StatelessWidget {
  final bool isUpdateEnable;
  final bool fromCheckout;
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController floorNumberController;
  final AddressModel? address;
  final String location;
  final String countryCode;

  const AddressButtonWidget({
    super.key,
    required this.isUpdateEnable,
    required this.fromCheckout,
    required this.contactPersonNumberController,
    required this.contactPersonNameController,
    required this.streetNumberController,
    required this.floorNumberController,
    required this.houseNumberController,
    required this.address,
    required this.location,
    required this.countryCode
  });

  @override
  Widget build(BuildContext context) {

    return Consumer<AddressProvider>(
      builder: (context, addressProvider, _) {
        return Column(children: [

          addressProvider.addressStatusMessage != null ?
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

            addressProvider.addressStatusMessage!.isNotEmpty ? const CircleAvatar(backgroundColor: Colors.green, radius: 5) : const SizedBox.shrink(),
            const SizedBox(width: 8),

            Expanded(child: Text(addressProvider.addressStatusMessage ?? "",
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.green, height: 1),
            ))
          ]): Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

            addressProvider.errorMessage!.isNotEmpty
                ? const CircleAvatar(backgroundColor: Colors.red, radius: 5)
                : const SizedBox.shrink(),
            const SizedBox(width: 8),

            Expanded(child: Text(
              addressProvider.errorMessage ?? "",
              style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.red, height: 1),
            ))

          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Container(
            height: 50.0,
            width: Dimensions.webScreenWidth,
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                return CustomButtonWidget(
                  isLoading: addressProvider.isLoading,
                  btnTxt: isUpdateEnable ? getTranslated('update_address', context) : getTranslated('save_location', context),
                  onTap: locationProvider.isLoading ? null : () async => _onPressAction(locationProvider, context),
                );
              },
            ),
          ),
        ]);
      }
    );
  }

  Future<void> _onPressAction(LocationProvider locationProvider, BuildContext context) async {
    final AddressProvider addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final LocationProvider locationProvider = context.read<LocationProvider>();
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final SplashProvider splashProvider = context.read<SplashProvider>();
    List<Branches> branches = Provider.of<SplashProvider>(context, listen: false).configModel!.branches!;
    bool isAvailable = branches.length == 1 && (branches[0].latitude == null || branches[0].latitude!.isEmpty);

    String phone  = (addressProvider.countryCode ?? "") + contactPersonNumberController.text.trim();
    bool isValidPhone = PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(phone);

    print("---------------(PHONE)-----------------$phone");
    print("---------------(IS VALID PHONE)--------$isValidPhone");

    if(!isValidPhone){
      showCustomSnackBar(getTranslated('invalid_phone_number', context), context);
    }else{
      if(!isAvailable) {
        if(splashProvider.configModel?.googleMapStatus ?? false){
          for (Branches branch in branches) {
            double distance = Geolocator.distanceBetween(
              double.parse(branch.latitude!), double.parse(branch.longitude!),
              double.tryParse(locationProvider.pickedAddressLatitude ?? '')
                  ?? locationProvider.currentPosition.latitude ,
              double.tryParse(locationProvider.pickedAddressLongitude ?? '') ?? locationProvider.currentPosition.longitude ,
            ) / 1000;

            if (distance < branch.coverage!) {
              isAvailable = true;
              break;
            }
          }
        }else{
          isAvailable = true;
        }
      }

      if(!isAvailable) {
        showCustomSnackBar(getTranslated('service_is_not_available', context), context);

      }
      else {

        AddressModel addressModel = AddressModel(
          addressType: addressProvider.getAllAddressType[addressProvider.selectAddressIndex],
          contactPersonName: contactPersonNameController.text.trim(),
          contactPersonNumber: phone,
          address: locationProvider.address,
          latitude: (splashProvider.configModel?.googleMapStatus ?? false)
              ? (locationProvider.pickedAddressLatitude?.isNotEmpty ?? false)
              ? locationProvider.pickedAddressLatitude.toString()
              : locationProvider.currentPosition.latitude.toString()
              : null,
          longitude: (splashProvider.configModel?.googleMapStatus ?? false)
              ? (locationProvider.pickedAddressLongitude?.isNotEmpty ?? false)
              ? locationProvider.pickedAddressLongitude.toString()
              : locationProvider.currentPosition.longitude.toString()
              : null,
          floorNumber: floorNumberController.text,
          houseNumber: houseNumberController.text,
          streetNumber: streetNumberController.text,
        );

        print('-------(ADDRESS IS )--------${addressModel.toJson().toString()}');
        print('-------(ADDRESS LAT LONG)-----${locationProvider.pickedAddressLatitude} and ${locationProvider.pickedAddressLongitude}');


        if (isUpdateEnable) {
          addressModel.id = address?.id;
          addressModel.userId = address?.userId;
          addressModel.method = 'put';
          await addressProvider.updateAddress(context, addressModel: addressModel, addressId: addressModel.id);

        } else {

          print('---------------------(Address Model)------------${addressModel.toJson().toString()}');

          await addressProvider.addAddress(addressModel, context).then((value) async{
            if (value.isSuccess) {

              if (fromCheckout) {
                await addressProvider.initAddressList();
                checkoutProvider.setOrderAddressIndex(-1);
                print("--------(HERE AM I)--------");
                CheckOutHelper.selectDeliveryAddressAuto(orderType: checkoutProvider.orderType, isLoggedIn: true, lastAddress: null);
              }


              if(ResponsiveHelper.isDesktop(context) && Navigator.canPop(context)){
                GoRouter.of(context).pop();
              }else if(!ResponsiveHelper.isDesktop(context)){
                Navigator.pop(context);
              }else{
                RouteHelper.getAddressRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
              }
              showCustomSnackBar(value.message, context, isError: false);

            } else {
              showCustomSnackBar(value.message, context);
            }
          });
        }
      }
    }
  }
}