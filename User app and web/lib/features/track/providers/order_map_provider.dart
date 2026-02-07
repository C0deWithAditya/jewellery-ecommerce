
import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexacom_user/features/order/domain/models/delivery_man_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/images.dart';


class OrderMapProvider extends ChangeNotifier {
  OrderMapProvider();

  GoogleMapController? _mapController;
  Set<Marker> _markers = HashSet<Marker>();

  late LatLng deliveryBoyLatLng;
  late LatLng addressLatLng;
  late LatLng restaurantLatLng;

  GoogleMapController? get getGoogleMapController => _mapController;
  Set<Marker> get markers => _markers;

  set setGoogleMapController(GoogleMapController? controller) => _mapController = controller;

  void disposeGoogleMapController()=> _mapController?.dispose();

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - 0.5;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }


  void setMapMarker({DeliveryManModel? deliveryManModel}) async {
    Uint8List restaurantImageData = await convertAssetToUnit8List(Images.restaurantMarker, width: 50);
    Uint8List deliveryBoyImageData = await convertAssetToUnit8List(Images.deliveryBoyMarker, width: 50);
    Uint8List destinationImageData = await convertAssetToUnit8List(Images.destinationMarker, width: 50);

    // Animate to coordinate
    LatLngBounds? bounds;
    double rotation = 0;

    if(deliveryManModel?.latitude != null) {
      deliveryBoyLatLng = LatLng(double.parse(deliveryManModel!.latitude!), double.parse(deliveryManModel.longitude!));
    }

    if(_mapController != null) {
      if (addressLatLng.latitude < restaurantLatLng.latitude) {
        bounds = LatLngBounds(southwest: addressLatLng, northeast: restaurantLatLng);
        rotation = 0;
      }else {
        bounds = LatLngBounds(southwest: restaurantLatLng, northeast: addressLatLng);
        rotation = 180;
      }
    }

    LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2
    );

    _mapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: 16),));
    if(ResponsiveHelper.isMobilePhone()){
      zoomToFit(_mapController, bounds, centerBounds);
    }

    // Marker
    _markers = HashSet<Marker>();
    _markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: addressLatLng,
      infoWindow: InfoWindow(
        title: getTranslated('destination', Get.context!),
        snippet: '${addressLatLng.latitude}, ${addressLatLng.longitude}',
      ),
      icon: BitmapDescriptor.fromBytes(destinationImageData),
    ));

    _markers.add(Marker(
      markerId: const MarkerId('branch'),
      position: restaurantLatLng,
      infoWindow: InfoWindow(
        title: getTranslated('branch', Get.context!),
        snippet: '${restaurantLatLng.latitude}, ${restaurantLatLng.longitude}',
      ),
      icon: BitmapDescriptor.fromBytes(restaurantImageData),
    ));

    deliveryManModel?.latitude != null ? _markers.add(Marker(
      markerId: const MarkerId('delivery_boy'),
      position: deliveryBoyLatLng,
      infoWindow: InfoWindow(
        title: getTranslated('delivery_boy', Get.context!),
        snippet: '${deliveryBoyLatLng.latitude}, ${deliveryBoyLatLng.longitude}',
      ),
      rotation: rotation,
      icon: BitmapDescriptor.fromBytes(deliveryBoyImageData),
    )) : const SizedBox();

    notifyListeners();
  }

}