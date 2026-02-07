import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/features/track/providers/order_map_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TrackingMapWidget extends StatefulWidget {
  final String? orderID;
  final DeliveryAddress? addressModel;
  const TrackingMapWidget( {Key? key, required this.orderID, required this.addressModel}) : super(key: key);

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
   OrderMapProvider orderMapProvider =  Provider.of<OrderMapProvider>(context, listen: false);

    EcommerceLocationCoverage coverage = Provider.of<SplashProvider>(context, listen: false).configModel!.ecommerceLocationCoverage!;

    orderMapProvider.addressLatLng = widget.addressModel != null ? LatLng(double.parse(widget.addressModel?.latitude ?? '0'), double.parse(widget.addressModel?.longitude ?? '0')) : const LatLng(0,0);
    orderMapProvider.restaurantLatLng = LatLng(double.parse(coverage.latitude!), double.parse(coverage.longitude!));
  }


  @override
  Widget build(BuildContext context) {

    OrderProvider orderProvider =  Provider.of<OrderProvider>(context, listen: false);


    return Consumer<OrderMapProvider>(
      builder: (context, orderMapProvider, _) {
        return Container(
          height: 200, width: MediaQuery.of(context).size.width - 100,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              GoogleMap(
                minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(target: orderMapProvider.addressLatLng, zoom: 16),
                zoomControlsEnabled: true,
                markers: orderMapProvider.markers,
                onMapCreated: (GoogleMapController controller) {
                  orderMapProvider.setGoogleMapController = controller;
                  _isLoading = false;

                  orderMapProvider.setMapMarker(deliveryManModel: orderProvider.deliveryManModel);

                },

                onTap: (latLng) async {

                  await orderProvider.getDeliveryManData(widget.orderID);

                  String url ='https://www.google.com/maps/dir/?api=1&origin=${orderProvider.deliveryManModel!.latitude},${orderProvider.deliveryManModel!.longitude}'
                      '&destination=${orderMapProvider.addressLatLng.latitude},${orderMapProvider.addressLatLng.longitude}&mode=d';

                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url, mode: LaunchMode.externalApplication);

                  } else {
                    throw 'Could not launch $url';

                  }
                },
              ),

             ResponsiveHelper.isWeb() ? const SizedBox() : _isLoading ? Center(
               child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
             ) : const SizedBox(),
            ],
          ),
        );
      }
    );
  }


}
