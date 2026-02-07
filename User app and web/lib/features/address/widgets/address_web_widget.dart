import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_button_widget.dart';
import 'package:hexacom_user/features/address/widgets/address_details_web_widget.dart';
import 'package:hexacom_user/features/address/widgets/address_map_web_widget.dart';
import 'package:hexacom_user/features/address/widgets/without_map_widget.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:provider/provider.dart';

class AddressWebWidget extends StatefulWidget {
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
  final TextEditingController floorNumberController;
  final FocusNode stateNode;
  final FocusNode houseNode;
  final FocusNode floorNode;
  const AddressWebWidget({
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
    required this.floorNumberController,
    required this.floorNode,
  });

  @override
  State<AddressWebWidget> createState() => _AddressWebWidgetState();
}

class _AddressWebWidgetState extends State<AddressWebWidget> {
  @override
  Widget build(BuildContext context) {

    final ConfigModel configModel = context.read<SplashProvider>().configModel!;
    final Size size = MediaQuery.of(context).size;
    final LocationProvider locationProvider = context.read<LocationProvider>();
    final AddressProvider addressProvider = context.read<AddressProvider>();

    print('-----------(ADDRESS WEB WIDGET)------------${widget.address?.toJson().toString()}');
    print('-----------(ADDRESS WEB WIDGET)------------${locationProvider.pickedAddressLatitude} and ${locationProvider.pickedAddressLongitude}');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: !(configModel.googleMapStatus?? false) ? size.width * 0.06: 0.0,
        vertical: !(configModel.googleMapStatus?? false) ? size.height * 0.02: 0.0,
      ),
      margin: EdgeInsets.symmetric(horizontal: !(configModel.googleMapStatus?? false) ? size.width * 0.08: 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color:Theme.of(context).shadowColor, blurRadius: 10)
        ],
      ),
      child: Column(children: [

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Expanded(flex: 5, child: AddressDetailsWebWidget(
            contactPersonNameController: widget.contactPersonNameController,
            contactPersonNumberController: widget.contactPersonNumberController,
            addressNode: widget.addressNode,
            nameNode: widget.nameNode,
            numberNode: widget.numberNode,
            isUpdateEnable: widget.isUpdateEnable,
            address: widget.address,
            fromCheckout: widget.fromCheckout,
            locationTextController: widget.locationTextController,
            streetNumberController: widget.streetNumberController,
            houseNumberController: widget.houseNumberController,
            houseNode: widget.houseNode,
            stateNode: widget.stateNode,
            florNumberController: widget.floorNumberController,
            florNode: widget.floorNode,
          )),

          if(configModel.googleMapStatus ?? false)...[
            Selector<LocationProvider, String?>(
              selector: (context, locationProvider) => locationProvider.pickedAddressLatitude,
              builder: (context, lat, child){
                
                return Expanded(flex : 6, child: Column(children: [

                  if(widget.address != null)...[

                    if(locationProvider.pickedAddressLongitude == null && locationProvider.pickedAddressLatitude == null)...[
                      const WithoutMapWidget(),
                    ],

                    if(locationProvider.pickedAddressLatitude != null && locationProvider.pickedAddressLongitude != null)...[
                      AddressMapWebWidget(
                        isUpdateEnable: widget.isUpdateEnable,
                        address: widget.address,
                        fromCheckout: widget.fromCheckout,
                        locationTextController: widget.locationTextController,
                      ),
                    ]

                  ],

                  if(widget.address == null)...[
                    AddressMapWebWidget(
                      isUpdateEnable: widget.isUpdateEnable,
                      address: widget.address,
                      fromCheckout: widget.fromCheckout,
                      locationTextController: widget.locationTextController,
                    ),
                  ],

                  Row(children: [

                    Expanded(child: Container()),

                    Expanded(child: AddressButtonWidget(
                      isUpdateEnable: widget.isUpdateEnable,
                      fromCheckout: widget.fromCheckout,
                      contactPersonNumberController: widget.contactPersonNumberController,
                      contactPersonNameController: widget.contactPersonNameController,
                      address: widget.address,
                      location: widget.locationTextController.text,
                      streetNumberController: widget.streetNumberController,
                      houseNumberController: widget.houseNumberController,
                      floorNumberController: widget.floorNumberController,
                      countryCode: addressProvider.countryCode ?? '',
                    )),

                  ]),

                ]));
              },
            ),
          ],


        ]),

        if(!(configModel.googleMapStatus?? false))...[
          Row(children: [

            Expanded(child: Container()),

            Expanded(child: AddressButtonWidget(
              isUpdateEnable: widget.isUpdateEnable,
              fromCheckout: widget.fromCheckout,
              contactPersonNumberController: widget.contactPersonNumberController,
              contactPersonNameController: widget.contactPersonNameController,
              address: widget.address,
              location: widget.locationTextController.text,
              streetNumberController: widget.streetNumberController,
              houseNumberController: widget.houseNumberController,
              floorNumberController: widget.floorNumberController,
              countryCode: addressProvider.countryCode ?? '',
            )),

            Expanded(child: Container()),

          ]),
        ],

      ]),
    );
  }
}


