import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/widgets/address_button_widget.dart';
import 'package:hexacom_user/features/address/widgets/address_details_widget.dart';
import 'package:hexacom_user/features/address/widgets/address_map_widget.dart';
import 'package:hexacom_user/features/address/widgets/address_web_widget.dart';
import 'package:hexacom_user/features/address/widgets/without_map_widget.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isUpdateEnable;
  final bool fromCheckout;
  final AddressModel? address;
  const AddNewAddressScreen({super.key, this.isUpdateEnable = true, this.address, this.fromCheckout = false});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _locationTextController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _florNumberController = TextEditingController();

  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _stateNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();




  @override
  void initState() {
    super.initState();
    _initLoading();

    if(widget.address != null && !widget.fromCheckout) {
      Provider.of<LocationProvider>(context, listen: false).setAddress = widget.address?.address;
      _locationTextController.text = widget.address!.address!;
    }
  }

  @override
  Widget build(BuildContext context) {

    final AddressProvider addressProvider = context.read<AddressProvider>();
    final LocationProvider locationProvider = context.read<LocationProvider>();

    return Scaffold(
      appBar: CustomAppBarWidget(title: widget.isUpdateEnable ? getTranslated('update_address', context) : getTranslated('add_new_address', context)),
      body: Selector<SplashProvider, ConfigModel?>(
        selector: (ctx, splashProvider)=> splashProvider.configModel,
        builder: (context, configModel,_) {

          addressProvider.setCountryCode(CountryCode.fromCountryCode(configModel!.countryCode!).dialCode ?? '');


          return Column(children: [

            Expanded(child: SingleChildScrollView(child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    CustomWebTitleWidget(title: getTranslated(widget.isUpdateEnable ? 'update_address' : 'add_new_address', context)),


                    if(!ResponsiveHelper.isDesktop(context) && (configModel?.googleMapStatus ?? false))...[
                      Selector<LocationProvider, String?>(
                        selector: (context, locationProvider) => locationProvider.pickedAddressLatitude,
                        builder: (context, lat, child) {

                          return Column(children: [

                            if(widget.address != null)...[
                              if(locationProvider.pickedAddressLongitude == null && locationProvider.pickedAddressLatitude == null)...[
                                const WithoutMapWidget(),
                              ],

                              if(locationProvider.pickedAddressLatitude != null && locationProvider.pickedAddressLongitude != null)...[
                                AddressMapWidget(
                                  isUpdateEnable: widget.isUpdateEnable,
                                  address: widget.address,
                                  fromCheckout: widget.fromCheckout,
                                  locationTextController: _locationTextController,
                                ),
                              ]
                            ],

                            if(widget.address == null)...[
                              AddressMapWidget(
                                isUpdateEnable: widget.isUpdateEnable,
                                address: widget.address,
                                fromCheckout: widget.fromCheckout,
                                locationTextController: _locationTextController,
                              ),
                            ],
                          ]);
                        },
                      ),
                    ],


                    // for label us
                    if(!ResponsiveHelper.isDesktop(context))
                      AddressDetailsWidget(
                        contactPersonNameController: _contactPersonNameController,
                        contactPersonNumberController: _contactPersonNumberController,
                        addressNode: _addressNode,
                        nameNode: _nameNode,
                        numberNode: _numberNode,
                        fromCheckout: widget.fromCheckout,
                        address: widget.address,
                        isUpdateEnable: widget.isUpdateEnable,
                        locationTextController: _locationTextController,
                        streetNumberController: _streetNumberController,
                        houseNumberController: _houseNumberController,
                        houseNode: _houseNode,
                        stateNode: _stateNode,
                        florNumberController: _florNumberController,
                        florNode: _floorNode,
                      ),

                    if(ResponsiveHelper.isDesktop(context))
                      AddressWebWidget(
                        contactPersonNameController: _contactPersonNameController,
                        contactPersonNumberController: _contactPersonNumberController,
                        addressNode: _addressNode,
                        nameNode: _nameNode,
                        numberNode: _numberNode,
                        fromCheckout: widget.fromCheckout,
                        address: widget.address,
                        isUpdateEnable: widget.isUpdateEnable,
                        locationTextController: _locationTextController,
                        streetNumberController: _streetNumberController,
                        houseNumberController: _houseNumberController,
                        houseNode: _houseNode,
                        stateNode: _stateNode,
                        floorNumberController: _florNumberController,
                        floorNode: _floorNode,
                      ),

                  ],
                ))),
              ),

              const FooterWebWidget(footerType: FooterType.nonSliver),
            ]))),

            if(!ResponsiveHelper.isDesktop(context))
              AddressButtonWidget(
                isUpdateEnable: widget.isUpdateEnable,
                fromCheckout: widget.fromCheckout,
                contactPersonNumberController: _contactPersonNumberController,
                contactPersonNameController: _contactPersonNameController,
                address: widget.address,
                location: _locationTextController.text,
                streetNumberController: _streetNumberController,
                houseNumberController: _houseNumberController,
                floorNumberController: _florNumberController,
                countryCode : addressProvider.countryCode ?? '',
              ),

          ]);
        }
      ),
    );
  }


  void _initLoading() async {

    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final AddressProvider addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final userModel =  Provider.of<ProfileProvider>(context, listen: false).userInfoModel ;
    final ConfigModel configModel = context.read<SplashProvider>().configModel!;
    final SplashProvider splashProvider = context.read<SplashProvider>();

    addressProvider.setCountryCode(CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!).dialCode ?? '');
    print('-----(FIRST COUNTRY CODE)-----${addressProvider.countryCode}');

    locationProvider.setPickedAddressLatLon(null, null, isUpdate: false);

    if(widget.address == null) {
      locationProvider.setLocationData(false);
    }

    await addressProvider.initializeAllAddressType(context: context);
    addressProvider.setAddressStatusMessage = '';
    addressProvider.setErrorMessage = '';

    print("-------------(LOCATION)-----------${widget.address?.toJson().toString()}");

    if (widget.isUpdateEnable && widget.address != null) {

      if(splashProvider.configModel?.googleMapStatus ?? false){

        if((widget.address?.longitude?.isNotEmpty ?? false)  && (widget.address?.latitude?.isNotEmpty ?? false)){
          locationProvider.updatePosition(CameraPosition(target: LatLng(double.parse(widget.address!.latitude!), double.parse(widget.address!.longitude!))), true, widget.address!.address, false);
          locationProvider.setPickedAddressLatLon(widget.address?.latitude ?? '', widget.address?.longitude ?? '');

          print("----------------(LOCATION)---------${locationProvider.pickedAddressLongitude} and ${locationProvider.pickedAddressLatitude}");

          locationProvider.updatePosition(
            CameraPosition(target: LatLng(
              double.parse(widget.address?.latitude ?? '0'),
              double.parse(widget.address?.longitude ?? '0'),
            )),
            true, widget.address!.address,false,
          );
        }
      }


      _contactPersonNameController.text = '${widget.address!.contactPersonName}';
      print('--------------(PHONE NUMBER)-----------${widget.address?.contactPersonNumber}');
      print('--------------(CountryCode)-----------${PhoneNumberCheckerHelper.getCountryCode('${widget.address!.contactPersonNumber}') ?? ''}');

      addressProvider.setCountryCode(PhoneNumberCheckerHelper.getCountryCode('${widget.address!.contactPersonNumber}') ?? '');
      _contactPersonNumberController.text = PhoneNumberCheckerHelper.getPhoneNumber('+${widget.address!.contactPersonNumber?.replaceAll('++', '+')}', addressProvider.countryCode ?? '') ?? '';
      _streetNumberController.text = widget.address!.streetNumber ?? '';
      _houseNumberController.text = widget.address!.houseNumber ?? '';
      _florNumberController.text = widget.address!.floorNumber ?? '';


      if (widget.address!.addressType == 'Home') {
        addressProvider.updateAddressIndex(0, false);

      } else if (widget.address!.addressType == 'Workplace') {
        addressProvider.updateAddressIndex(1, false);

      } else {
        addressProvider.updateAddressIndex(2, false);

      }
    }else {
      _contactPersonNameController.text = '${userModel?.fName ?? ''}'
          ' ${userModel?.lName ?? ''}';
      addressProvider.setCountryCode(PhoneNumberCheckerHelper.getCountryCode(userModel?.phone ?? CountryCode.fromCountryCode(configModel.countryCode!).dialCode) ?? '', isUpdate: true);
      _contactPersonNumberController.text = PhoneNumberCheckerHelper.getPhoneNumber(userModel?.phone ?? '', addressProvider.countryCode ?? '') ?? '';
      _streetNumberController.text = widget.address?.streetNumber ?? '';
      _houseNumberController.text = widget.address?.houseNumber ?? '';
      _florNumberController.text = widget.address?.floorNumber ?? '';

      print('--------------------(ELSE)---------------${userModel?.phone}---------');
      print('--------------------(ELSE)----------------${PhoneNumberCheckerHelper.getCountryCode(userModel?.phone)}');
      print('--------------------(ELSE)-------------------${_contactPersonNumberController.text}');
      print('--------------------(ELSE)-------------------${PhoneNumberCheckerHelper.getPhoneNumber(userModel?.phone ?? '', addressProvider.countryCode ?? '') ?? ''}');
      print('-------------------(ELSE)------------${addressProvider.countryCode}');

    }


  }

}









