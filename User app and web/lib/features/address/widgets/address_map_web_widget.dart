import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/screens/select_location_screen.dart';
import 'package:hexacom_user/features/address/widgets/location_permission_dialog_widget.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddressMapWebWidget extends StatefulWidget {
  final bool isUpdateEnable;
  final bool fromCheckout;
  final AddressModel? address;
  final TextEditingController locationTextController;

  const AddressMapWebWidget({
    super.key,
    required this.isUpdateEnable,
    required this.address,
    required this.fromCheckout,
    required this.locationTextController,
  });

  @override
  State<AddressMapWebWidget> createState() => _AddressMapWidgetState();
}

class _AddressMapWidgetState extends State<AddressMapWebWidget> {
  CameraPosition? _cameraPosition;
  GoogleMapController? _controller;
  bool _updateAddress = true;



  @override
  void initState() {
    super.initState();

    // if(widget.address != null) {
    //   _initialPosition = LatLng(double.parse(widget.address!.latitude!), double.parse(widget.address!.longitude!));
    // }else{
    //   _initialPosition = LatLng(
    //     double.parse(Provider.of<SplashProvider>(context, listen: false).configModel!.branches![0].latitude ?? '0'),
    //     double.parse(Provider.of<SplashProvider>(context, listen: false).configModel!.branches![0].longitude ?? '0'),
    //   );
    // }

    if (widget.isUpdateEnable && widget.address != null) {
      _updateAddress = false;
    }


  }


  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    final branch = Provider.of<SplashProvider>(context, listen: false).configModel!.branches![0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),

      child: Consumer<AddressProvider>(builder: (context, addressProvider, _) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          const SizedBox(height: Dimensions.paddingSizeLarge),

          Consumer<LocationProvider>(builder: (context, locationProvider, child) {
            return SizedBox(height: size.height * 0.5, width: MediaQuery.of(context).size.width,
              child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                child: Stack(clipBehavior: Clip.none, children: [

                  GoogleMap(
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: (widget.isUpdateEnable && (locationProvider.pickedAddressLatitude?.isNotEmpty ?? false) && (locationProvider.pickedAddressLongitude?.isNotEmpty ?? false)) ?  LatLng(
                        double.parse(locationProvider.pickedAddressLatitude!),
                        double.parse(locationProvider.pickedAddressLongitude!),
                      )  : LatLng(locationProvider.currentPosition.latitude.toInt()  == 0
                          ? double.parse(branch.latitude!)
                          : locationProvider.currentPosition.latitude, locationProvider.currentPosition.longitude.toInt() == 0
                          ? double.parse(branch.longitude!)
                          : locationProvider.currentPosition.longitude,
                      ),
                      zoom: 16,
                    ),
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    indoorViewEnabled: true,
                    mapToolbarEnabled: false,
                    onCameraIdle: ()=> _onCameraIdle(locationProvider),
                    onCameraMove: ((position) => _cameraPosition = position),
                    onMapCreated: (GoogleMapController controller) {

                      if (!widget.isUpdateEnable && _controller != null) {
                        _checkPermission(() =>
                          locationProvider.getCurrentLocation(context, true, mapController: _controller)
                        );
                      }

                      _controller = controller;
                      if (!widget.isUpdateEnable && _controller != null) {
                        if(locationProvider.pickedAddressLatitude == null && locationProvider.pickedAddressLongitude == null){
                          _checkPermission(()=>locationProvider.getCurrentLocation(
                            context, true, mapController: _controller,
                          ));
                        }else{
                          Future.delayed(const Duration(milliseconds: 800)).then((value) {
                            _controller = controller;
                            _controller?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                              target:  LatLng(
                                double.parse(locationProvider.pickedAddressLatitude ?? '0'),
                                double.parse(locationProvider.pickedAddressLongitude ?? '0'),
                              ), zoom: 17,
                            )));
                          });
                        }
                        // _checkPermission(() {
                        //   locationProvider.getCurrentLocation(context, true, mapController: _controller);
                        // });
                      }else{
                        Future.delayed(const Duration(milliseconds: 800)).then((value) {
                          _controller = controller;
                          double latitude = double.tryParse(locationProvider.pickedAddressLatitude ?? '') ?? 0;
                          double longitude = double.tryParse(locationProvider.pickedAddressLongitude ?? '') ?? 0;
                          _controller?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                            target:  LatLng(latitude, longitude), zoom: 17,
                          )));
                        });
                      }
                    },
                  ),

                  if(locationProvider.isLoading) Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  )),

                  Container(width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    child: const CustomAssetImageWidget(Images.marker, width: 25, height: 35),
                  ),

                  Positioned(bottom: 10, right: 0,
                    child: InkWell(
                      onTap: () => _checkPermission(() {
                        locationProvider.getCurrentLocation(context, true, mapController: _controller);
                      }),
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                        height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                          color: Colors.white,
                        ),
                        child: Icon(Icons.my_location, color: Theme.of(context).primaryColor, size: 20),
                      ),
                    ),
                  ),

                  Positioned(top: 10, right: 0, child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SelectLocationScreen(googleMapController: _controller),
                      ));
                    },
                    child: Container(
                      width: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                      height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        color: Colors.white,
                      ),
                      child: Icon(Icons.fullscreen, color: Theme.of(context).primaryColor, size: 20),
                    ),
                  )),

                ]),

              )
            );
          }),

          Padding(padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Text(getTranslated('add_the_location_correctly', context),
                style: rubikMedium.copyWith(color: ColorResources.getGreyBunkerColor(context), fontSize: Dimensions.fontSizeSmall),
              ),
            ),
          ),

        ]);
      }),
    );
  }

  void _checkPermission(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if(permission == LocationPermission.denied) {
      widget.locationTextController.clear();
      permission = await Geolocator.requestPermission();
    }else if(permission == LocationPermission.deniedForever) {
      showDialog(context: Get.context!, barrierDismissible: false, builder: (context) => const LocationPermissionDialogWidget());
    }else {
      callback();
    }
  }

  void _onCameraIdle(LocationProvider locationProvider){
    if(widget.address != null && !widget.fromCheckout) {
      locationProvider.updatePosition(_cameraPosition, true, null, true);
      _updateAddress = true;

    }else {
      if(_updateAddress) {
        locationProvider.updatePosition(_cameraPosition, true, null, true);

      }else {
        _updateAddress = true;
      }
    }
  }
}