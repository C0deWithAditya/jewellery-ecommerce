import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class DeleteDialogWidget extends StatelessWidget {
  final AddressModel addressModel;
  final int index;
  const DeleteDialogWidget({Key? key, required this.addressModel, required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 300,
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          const SizedBox(height: 20),
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.contact_support, size: 50),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: FittedBox(
              child: Text(getTranslated('want_to_delete', context), style: rubikBold, textAlign: TextAlign.center, maxLines: 1),
            ),
          ),

          Divider(height: 0, color: Theme.of(context).hintColor),

           Row(children: [

            Expanded(child: InkWell(
              onTap: () {
                showDialog(context: context, barrierDismissible: false, builder: (context) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ));
                Provider.of<AddressProvider>(context, listen: false).deleteUserAddressByID(addressModel.id, index, (bool isSuccessful, String message) {
                  Navigator.pop(context);
                  showCustomSnackBar(message, context, isError: !isSuccessful);
                  Navigator.pop(context);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                alignment: Alignment.center,
                decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10))),
                child: Text(getTranslated('yes', context), style: rubikBold.copyWith(color: Theme.of(context).primaryColor)),
              ),
            )),

            Expanded(child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10)),
                ),
                child: Text(getTranslated('no', context), style: rubikBold.copyWith(color: Colors.white)),
              ),
            )),

          ])
          //      : Padding(
          //   padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          //   child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          // ),
        ]),
      ),
    );
  }
}
