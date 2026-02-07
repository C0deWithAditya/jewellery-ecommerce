import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/features/auth/widgets/code_picker_widget.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';

class PhoneNumberFieldWidget extends StatelessWidget {
  const PhoneNumberFieldWidget({
    super.key,
    required this.onValueChange,
    required this.countryCode,
    required this.phoneNumberTextController,
    required this.phoneFocusNode,
  });

  final Function(String value) onValueChange;
  final String? countryCode;
  final TextEditingController phoneNumberTextController;
  final FocusNode phoneFocusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Row(children: [
        CodePickerWidget(
          onChanged: (CountryCode value)=> onValueChange(value.code!),
          initialSelection: countryCode,
          favorite: [countryCode ?? ''],
          showDropDownButton: true,
          padding: EdgeInsets.zero,
          showFlagMain: true,
          textStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),
        ),

        Container(width: 1, height: Dimensions.paddingSizeExtraLarge, color: Theme.of(context).dividerColor),

        Expanded(child: CustomTextFieldWidget(
          borderColor: Colors.transparent,
          hintText: getTranslated('enter_phone_number', context),
          isShowBorder: true,
          controller: phoneNumberTextController,
          focusNode: phoneFocusNode,
          inputType: TextInputType.phone,
          contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: 20),
        )),

      ]),
    );
  }
}