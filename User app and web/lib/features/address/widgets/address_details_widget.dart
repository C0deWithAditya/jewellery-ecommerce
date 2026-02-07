import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_button_widget.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressDetailsWidget extends StatelessWidget {
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

  const AddressDetailsWidget({
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
    final AddressProvider addressProvider = context.read<AddressProvider>();

    return Padding(
      padding: ResponsiveHelper.isDesktop(context) ?  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeLarge) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              getTranslated('delivery_address', context),
              style:
              rubikRegular.copyWith(color: ColorResources.getGreyBunkerColor(context), fontSize: Dimensions.fontSizeLarge),
            ),
          ),
          // for Address Field
          Text(
            getTranslated('address_line_01', context),
            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Selector<LocationProvider, String?>(
            selector: (context, locationProvider) => locationProvider.address,
            builder: (context, address, child){

              print("-------------(Address)--------------${locationProvider.address}");

              locationTextController.text = locationProvider.address ?? '';
              return CustomTextFieldWidget(
                onChanged: (String? value) => locationProvider.setAddress = value,
                hintText: getTranslated('address_line_02', context),
                isShowBorder: true,
                inputType: TextInputType.streetAddress,
                inputAction: TextInputAction.next,
                focusNode: addressNode,
                nextFocus: nameNode,
                controller: locationTextController,
              );
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            '${getTranslated('street', context)} ${getTranslated('number', context)}',
            style: rubikRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          CustomTextFieldWidget(
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

          Text(
            '${getTranslated('house', context)} / ${
                getTranslated('floor', context)} ${
                getTranslated('number', context)}',
            style: rubikRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(
              child: CustomTextFieldWidget(
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

            Expanded(
              child: CustomTextFieldWidget(
                hintText: getTranslated('ex_2b', context),
                isShowBorder: true,
                inputType: TextInputType.streetAddress,
                inputAction: TextInputAction.next,
                focusNode: florNode,
                nextFocus: nameNode,
                controller: florNumberController,
                maxLength: 10,
              ),
            ),

          ],),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // for Contact Person Name
          Text(
            getTranslated('contact_person_name', context),
            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextFieldWidget(
            hintText: getTranslated('enter_contact_person_name', context),
            isShowBorder: true,
            inputType: TextInputType.name,
            controller: contactPersonNameController,
            focusNode: nameNode,
            nextFocus: numberNode,
            inputAction: TextInputAction.next,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // for Contact Person Number
          Text(
            getTranslated('contact_person_number', context),
            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextFieldWidget(
            hintText: getTranslated('enter_contact_person_number', context),
            isShowBorder: true,
            inputType: TextInputType.phone,
            inputAction: TextInputAction.done,
            focusNode: numberNode,
            controller: contactPersonNumberController,
            countryDialCode: addressProvider.countryCode,
            onCountryChanged: (CountryCode value) {
              addressProvider.setCountryCode(value.dialCode ?? '', isUpdate: true);
            },
            onChanged: (String text) => AuthHelper.identifyEmailOrNumber(text, context),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          if(ResponsiveHelper.isDesktop(context)) Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: AddressButtonWidget(
              isUpdateEnable: isUpdateEnable,
              fromCheckout: fromCheckout,
              contactPersonNumberController: contactPersonNumberController,
              contactPersonNameController: contactPersonNameController,
              address: address,
              location: locationTextController.text,
              streetNumberController: streetNumberController,
              houseNumberController: houseNumberController,
              floorNumberController: florNumberController,
              countryCode: addressProvider.countryCode ?? '',
            ),
          )
        ],
      ),
    );
  }
}