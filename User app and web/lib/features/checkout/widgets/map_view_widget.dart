import 'dart:collection';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/delivery_address_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/zip_code_view_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapViewWidget extends StatefulWidget {
  final bool isSelfPickUp;
  final GlobalKey? dropDownKey;
  final double? discount;
  final double? amount;
  const MapViewWidget({super.key, required this.isSelfPickUp, this.dropDownKey, this.discount, this.amount});

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {

  late GoogleMapController _mapController;
  List<Branches>? _branches = [];
  bool _loading = true;
  Set<Marker> _markers = HashSet<Marker>();

  @override
  void initState() {
    super.initState();



  }

  @override
  Widget build(BuildContext context) {

    final ConfigModel configModel = context.read<SplashProvider>().configModel!;
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final bool isLoggedIn = context.read<AuthProvider>().isLoggedIn();
    double deliveryCharge = 0.0;

    return Consumer<SplashProvider>( builder: (context, splashProvider,_){
      _branches = splashProvider.configModel!.branches;
      return Consumer<CheckoutProvider>( builder: (context, checkoutProvider, _) {
        return Column(
          children: [
            //_branches!.length > 1 ?
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ).copyWith(top: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0.0),
                child: Text(getTranslated('select_branch', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _branches!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      child: InkWell(
                        onTap: () async {
                          checkoutProvider.setBranchIndex(index);
                          orderProvider.setAreaID(isReload: true);
                          orderProvider.setDeliveryCharge(null);
                          await CheckOutHelper.selectDeliveryAddressAuto(orderType: widget.isSelfPickUp ? 'self_pickup' : 'delivery', isLoggedIn: (isLoggedIn || CheckOutHelper.isGuestCheckout(context)));

                          deliveryCharge = CheckOutHelper.getDeliveryCharge(
                            context: context,
                            freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
                            orderAmount: widget.amount ?? 0.0,
                            distance: checkoutProvider.distance,
                            discount: widget.discount ?? 0.0,
                            configModel: configModel,
                            isSelfPickUp: widget.isSelfPickUp,
                          );
                          orderProvider.setDeliveryCharge(deliveryCharge);
                          _setMarkers(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index == checkoutProvider.branchIndex ? Theme.of(context).primaryColor : Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Text(_branches![index].name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: rubikMedium.copyWith(
                            color: index == checkoutProvider.branchIndex ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                          )),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if(configModel.googleMapStatus ?? false)...[
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                      color: Theme.of(context).cardColor,
                      border: Border.all(width: 1, color: Theme.of(context).primaryColor.withOpacity(0.5))
                  ),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                      child: GoogleMap(
                        minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(target: LatLng(
                          double.parse(_branches![0].latitude!),
                          double.parse(_branches![0].longitude!),
                        ), zoom: 16),
                        zoomControlsEnabled: true,
                        markers: _markers,
                        onMapCreated: (GoogleMapController controller) async {
                          await Geolocator.requestPermission();
                          _mapController = controller;
                          _loading = false;
                          _setMarkers(0);
                        },
                      ),
                    ),

                    _loading ? Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    )) : const SizedBox(),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault)
              ],

              if(ResponsiveHelper.isDesktop(context) && CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.area.name && !widget.isSelfPickUp)...[
                ZipCodeViewWidget(
                  dropDownKey: widget.dropDownKey!,
                  discount: widget.discount ?? 0.0,
                  amount: widget.amount ?? 0.0,
                  isSelfPickUp: widget.isSelfPickUp,
                ),
              ],

              if(ResponsiveHelper.isDesktop(context) && !widget.isSelfPickUp)
                DeliveryAddressWidget(selfPickup: widget.isSelfPickUp),

            ])



          ],
        );
      });
    });
  }

  void _setMarkers(int selectedIndex) async {
    late BitmapDescriptor bitmapDescriptor;
    late BitmapDescriptor bitmapDescriptorUnSelect;
    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(30, 50)), Images.restaurantMarker).then((marker) {
      bitmapDescriptor = marker;
    });
    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(20, 20)), Images.unselectedRestaurantMarker).then((marker) {
      bitmapDescriptorUnSelect = marker;
    });

    // Marker
    _markers = HashSet<Marker>();
    for(int index=0; index<_branches!.length; index++) {
      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.parse(_branches![index].latitude!), double.parse(_branches![index].longitude!)),
        infoWindow: InfoWindow(title: _branches![index].name, snippet: _branches![index].address),
        icon: selectedIndex == index ? bitmapDescriptor : bitmapDescriptorUnSelect,
      ));
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
      double.parse(_branches![selectedIndex].latitude!),
      double.parse(_branches![selectedIndex].longitude!),
    ), zoom: ResponsiveHelper.isMobile(Get.context!) ? 12 : 16)));

    setState(() {});
  }

}
