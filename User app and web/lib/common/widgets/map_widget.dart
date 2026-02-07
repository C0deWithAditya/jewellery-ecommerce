import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:ui';

import 'web_app_bar_widget.dart';

class MapWidget extends StatefulWidget {
  final DeliveryAddress? address;
  const MapWidget({super.key, required this.address});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late LatLng _latLng;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    _latLng = LatLng(double.parse(widget.address!.latitude!), double.parse(widget.address!.longitude!));
    _setMarker();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()):  CustomAppBarWidget(title: getTranslated('delivery_address', context))) as PreferredSizeWidget?,
      body: SingleChildScrollView(
        physics: ResponsiveHelper.isDesktop(context) ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0 ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0 ),
                  decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                    color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
                  ) : null,
                  height: ResponsiveHelper.isDesktop(context) ?   height * 0.7 : height * 0.9,
                  width: Dimensions.webScreenWidth,
                  child: Stack(children: [
                    GoogleMap(
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                      initialCameraPosition: CameraPosition(target: _latLng, zoom: 16),
                      zoomGesturesEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      indoorViewEnabled: true,
                      markers:_markers,
                    ),
                    Positioned(
                      left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge,
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).cardColor,
                          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 3, blurRadius: 10)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(children: [

                              Icon(
                                widget.address!.addressType == 'Home' ? Icons.home_outlined : widget.address!.addressType == 'Workplace'
                                    ? Icons.work_outline : Icons.list_alt_outlined,
                                size: 30, color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                                  Text(widget.address!.addressType!, style: rubikRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall, color: ColorResources.getGreyBunkerColor(context),
                                  )),

                                  Text(widget.address!.address!, style: rubikMedium),

                                ]),
                              ),
                            ]),

                            Text('- ${widget.address!.contactPersonName}', style: rubikMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeLarge,
                            )),

                            Text('- ${widget.address!.contactPersonNumber}', style: rubikRegular),

                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: Dimensions.paddingSizeLarge),
            const FooterWebWidget(footerType: FooterType.nonSliver),
          ],
        ),
      ),
    );
  }

  void _setMarker() async {
    Uint8List destinationImageData = await convertAssetToUnit8List(Images.destinationMarker, width: 70);

    _markers = {};
    _markers.add(Marker(
      markerId: const MarkerId('marker'),
      position: _latLng,
      icon: BitmapDescriptor.bytes(destinationImageData),
    ));

    setState(() {});
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

}
