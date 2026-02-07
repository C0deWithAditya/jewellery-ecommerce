import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

class LocationSearchDialogWidget extends StatelessWidget {
  final GoogleMapController? mapController;
  const LocationSearchDialogWidget({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final AddressProvider addressProvider = Provider.of<AddressProvider>(context, listen: false);

    return Scrollable(viewportBuilder: (context, _)=> Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault).copyWith(top: 80),
        alignment: Alignment.topCenter,
        child: Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(width: Dimensions.webScreenWidth, child: TypeAheadField<Prediction>(
            builder: (context, controller, focusNode) => TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                hintText: getTranslated('search_location', context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(style: BorderStyle.none, width: 0),
                ),
                hintStyle: rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor,
                ),
                filled: true, fillColor: Theme.of(context).cardColor,
              ),
              style: rubikMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeLarge,
              ),
            ),
            suggestionsCallback: (pattern) async {
              return await addressProvider.searchAddress(context, pattern);
            },
            itemBuilder: (context, Prediction suggestion) {
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(children: [
                  const Icon(Icons.location_on),
                  Expanded(
                    child: Text(suggestion.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: rubikMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeLarge,
                    )),
                  ),
                ]),
              );
            },
            onSelected: (Prediction suggestion) {
              print("-----------------(ON SELECTED)----------${suggestion.toJson().toString()}");
              locationProvider.setLocation(suggestion.placeId, suggestion.description, mapController);
              Navigator.pop(context);
            },
          )),
        ),
      ),
    );
  }
}
