import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressDetailsWebWidget extends StatelessWidget {
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final FocusNode addressNode;
  final FocusNode nameNode;
  final FocusNode numberNode;
  final bool isUpdateEnable;
  final bool fromCheckout;
  final AddressModel? address;
  final TextEditingController locationTextController;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController florNumberController;
  final FocusNode stateNode;
  final FocusNode houseNode;
  final FocusNode florNode;

  const AddressDetailsWebWidget({
    super.key,
    required this.contactPersonNameController,
    required this.contactPersonNumberController,
    required this.addressNode, required this.nameNode,
    required this.numberNode,
    required this.isUpdateEnable,
    required this.fromCheckout,
    required this.address,
    required this.locationTextController,
    required this.streetNumberController,
    required this.houseNumberController,
    required this.stateNode,
    required this.houseNode,
    required this.florNumberController,
    required this.florNode,
  });



  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = context.read<LocationProvider>();
    locationTextController.text = Provider.of<LocationProvider>(context).address ?? '';

    return Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeLarge) ,
      child: Consumer<AddressProvider>(
        builder:  (context, addressProvider, _){

          print("Country Code ====>>>> ${addressProvider.countryCode}");

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [

              Expanded(child: CustomTextFieldWidget(
                title: getTranslated("name", context),
                isRequired: true,
                hintText: getTranslated('enter_contact_person_name', context),
                isShowBorder: true,
                inputType: TextInputType.name,
                controller: contactPersonNameController,
                focusNode: nameNode,
                nextFocus: numberNode,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
              )),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              // for Contact Person Number
              Expanded(child: CustomTextFieldWidget(
                countryDialCode: addressProvider.countryCode,
                onCountryChanged: (CountryCode value) => addressProvider.setCountryCode(value.dialCode ?? '', isUpdate: true) ,
                isRequired: true,
                title: getTranslated('phone_number', context),
                hintText: getTranslated('enter_contact_person_number', context),
                isShowBorder: true,
                inputType: TextInputType.phone,
                inputAction: TextInputAction.done,
                focusNode: numberNode,
                controller: contactPersonNumberController,
              )),
              const SizedBox(height: Dimensions.paddingSizeLarge),

            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(getTranslated('label_as', context),
              style: rubikRegular.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Selector<AddressProvider, int>(
                selector: (context, addressProvider) => addressProvider.selectAddressIndex,
                builder: (context, addressIndex, child) {
                  return SizedBox(height: 50,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: addressProvider.getAllAddressType.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: ()=> addressProvider.updateAddressIndex(index, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
                          margin: const EdgeInsets.only(right: 17),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            border: Border.all(
                              color: addressProvider.selectAddressIndex == index ? Theme.of(context).primaryColor : Theme.of(context).dividerColor.withOpacity(0.5),
                            ),
                            color: addressProvider.selectAddressIndex == index ? Theme.of(context).primaryColor : Theme.of(context).dividerColor.withOpacity(0.3),
                          ),
                          child: Row(children: [

                            CustomAssetImageWidget(
                              index == 0 ? Images.homeIcon : index == 1 ? Images.workPlaceIcon : Images.mapIcon,
                              color: index == addressProvider.selectAddressIndex ? Theme.of(context).cardColor : Theme.of(context).hintColor,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeDefault),

                            Text(getTranslated(addressProvider.getAllAddressType[index].toLowerCase(), context),
                              style: rubikMedium.copyWith(
                                color: addressProvider.selectAddressIndex == index ? Colors.white : Colors.black,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  );
                }
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(getTranslated('address_line_01', context),
              style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CustomTextFieldWidget(
              onChanged: (String? value) => locationProvider.setAddress = value,
              hintText: getTranslated('address_line_02', context),
              isShowBorder: true,
              inputType: TextInputType.streetAddress,
              inputAction: TextInputAction.next,
              focusNode: addressNode,
              nextFocus: nameNode,
              controller: locationTextController,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomTextFieldWidget(
              title: '${getTranslated('street', context)} ${getTranslated('number', context)}',
              hintText: getTranslated('ex_10_th', context),
              isShowBorder: true,
              inputType: TextInputType.streetAddress,
              inputAction: TextInputAction.next,
              focusNode: stateNode,
              nextFocus: houseNode,
              controller: streetNumberController,
              maxLength: 50,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(children: [

              Expanded(
                child: CustomTextFieldWidget(
                  title: getTranslated('house', context),
                  hintText: getTranslated('ex_2', context),
                  isShowBorder: true,
                  inputType: TextInputType.streetAddress,
                  inputAction: TextInputAction.next,
                  focusNode: houseNode,
                  nextFocus: florNode,
                  controller: houseNumberController,
                  maxLength: 50,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),

              Expanded(child: CustomTextFieldWidget(
                title: getTranslated('floor', context),
                hintText: getTranslated('ex_2b', context),
                isShowBorder: true,
                inputType: TextInputType.streetAddress,
                inputAction: TextInputAction.next,
                focusNode: florNode,
                nextFocus: nameNode,
                controller: florNumberController,
                maxLength: 10,
              )),

            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

          ]);
        },
      ),
    );
  }
}