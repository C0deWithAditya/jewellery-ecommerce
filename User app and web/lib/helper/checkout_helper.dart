import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/delivery_fee_dialog_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckOutHelper {

  static AddressModel? getDeliveryAddress({
    required List<AddressModel?>? addressList,
    required AddressModel? selectedAddress,
    required AddressModel? lastOrderAddress,
  }){
    AddressModel? deliveryAddress;
    if(selectedAddress != null) {
      deliveryAddress = selectedAddress;
    }else if(lastOrderAddress != null){
      deliveryAddress = lastOrderAddress;
    }else if(addressList != null && addressList.isNotEmpty){
      deliveryAddress = addressList.first;
    }

    return deliveryAddress;
  }

  static bool isBranchAvailable({required List<Branches> branches, required Branches selectedBranch, required AddressModel selectedAddress}){
    bool isAvailable = branches.length == 1 && (branches[0].latitude == null || branches[0].latitude!.isEmpty);

    if(!isAvailable) {
      double distance = Geolocator.distanceBetween(
        double.parse(selectedBranch.latitude!), double.parse(selectedBranch.longitude!),
        double.parse(selectedAddress.latitude!), double.parse(selectedAddress.longitude!),
      ) / 1000;

      isAvailable = distance < selectedBranch.coverage!;
    }

    return isAvailable;
  }

  static bool isKmWiseCharge({required ConfigModel? configModel}) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(Get.context!, listen: false);
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(Get.context!, listen: false);
    return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.deliveryChargeType == DeliveryChargeType.distance.name;
  }


  static Future<void> selectDeliveryAddress(BuildContext context,{
    required bool isAvailable,
    required int index,
    required ConfigModel configModel,
    required bool fromAddressList,
  }) async {

    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final AddressProvider addressProvider = context.read<AddressProvider>();
    final OrderProvider orderProvider = context.read<OrderProvider>();


    print('---------------(5)--------------- $isAvailable');
    if(isAvailable) {

      addressProvider.updateAddressIndex(index, fromAddressList);
      checkoutProvider.setOrderAddressIndex(index, notify: false);


      if(CheckOutHelper.isKmWiseCharge(configModel: configModel)) {
        if(fromAddressList) {
          if(checkoutProvider.selectedPaymentMethod != null){
            showCustomSnackBar(getTranslated('your_payment_method_has_been', Get.context!), Get.context!, isError: false);
          }
          checkoutProvider.savePaymentMethod(index: null, method: null);

        }
        print('------------------------(6)-------------');
        showDialog(context: Get.context!, builder: (context) => Center(child: Container(
          height: 100, width: 100, alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
          child: CustomLoaderWidget(color: Theme.of(context).primaryColor),
        )), barrierDismissible: false);

        bool isSuccess = await checkoutProvider.getDistanceInMeter(
          LatLng(
            double.parse(configModel.branches![checkoutProvider.branchIndex].latitude!),
            double.parse(configModel.branches![checkoutProvider.branchIndex].longitude!),
          ),
          LatLng(
            double.parse(addressProvider.addressList![index].latitude!),
            double.parse(addressProvider.addressList![index].longitude!),
          ),
        );

        print('-----------------(DISTANCE)---------${checkoutProvider.distance}---------');

        Navigator.pop(Get.context!);

        if(fromAddressList) {
          Navigator.pop(context);
          await showDialog(context: Get.context!, builder: (context) => DeliveryFeeDialogWidget(
            freeDelivery: checkoutProvider.getCheckOutData?.freeDeliveryType == 'free_delivery',
            amount: checkoutProvider.getCheckOutData?.amount ?? 0,
            distance: checkoutProvider.distance,
            callBack: (deliveryCharge){
              checkoutProvider.getCheckOutData?.copyWith(deliveryCharge: deliveryCharge);
              orderProvider.setDeliveryCharge(checkoutProvider.getCheckOutData?.deliveryCharge);
            },
          ));
        }else{
          print('---------(6)--------------');
          checkoutProvider.getCheckOutData?.copyWith(deliveryCharge: CheckOutHelper.getDeliveryCharge(
            context: Get.context!,
            isSelfPickUp: checkoutProvider.getCheckOutData?.orderType == 'self_pickup',
            freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
            orderAmount: checkoutProvider.getCheckOutData?.amount ?? 0,
            distance: checkoutProvider.distance,
            discount: checkoutProvider.getCheckOutData?.placeOrderDiscount ?? 0,
            configModel: configModel,
          ));
          orderProvider.setDeliveryCharge(checkoutProvider.getCheckOutData?.deliveryCharge);
        }

        if(!isSuccess){
          showCustomSnackBar(getTranslated('failed_to_fetch_distance', Get.context!), Get.context!);
        }
      }else{
        print('---------(6)--------------');
        checkoutProvider.getCheckOutData?.copyWith(deliveryCharge: CheckOutHelper.getDeliveryCharge(
          context: Get.context!,
          isSelfPickUp: checkoutProvider.getCheckOutData?.orderType == 'self_pickup',
          freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
          orderAmount: checkoutProvider.getCheckOutData?.amount ?? 0,
          distance: checkoutProvider.distance,
          discount: checkoutProvider.getCheckOutData?.placeOrderDiscount ?? 0,
          configModel: configModel,
        ));
        orderProvider.setDeliveryCharge(checkoutProvider.getCheckOutData?.deliveryCharge);
        print("-----------------------(OrderProvider delivery Charge)------${orderProvider.deliveryCharge}");
      }

    }else{
      showCustomSnackBar(getTranslated('out_of_coverage_for_this_branch', Get.context!), Get.context!);
    }
  }


  static double getDeliveryCharge({
    required double orderAmount,
    bool? isSelfPickUp,
    required double distance,
    required double discount,
    required String? freeDeliveryType,
    required ConfigModel configModel,
    required BuildContext context,
  }) {
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();

    print("---------------(DeliveryCharge Order Amount)-----------------$orderAmount");
    print("---------------(DeliveryCharge Discount)-----------------$discount");
    print("---------------(DeliveryCharge OrderType)-----------------${orderProvider.orderType}");
    print("---------------(DeliveryCharge Distance)-----------------$distance");
    print("---------------(DeliveryCharge Delivery Charge Per Km)----------${getDeliveryChargePerKm(context)}");

    double deliveryCharge = 0;


    if(freeDeliveryType == 'free_delivery' || (isSelfPickUp ?? false)){
      deliveryCharge = 0;
    }else{
      if(getDeliveryChargeType(context) == DeliveryChargeType.fixed.name){
        deliveryCharge = splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.fixedDeliveryCharge?.toDouble() ?? 0.0;
      }else if(getDeliveryChargeType(context) == DeliveryChargeType.distance.name && distance != -1 && distance > getMinimumDistanceForFreeDelivery(context)){
        deliveryCharge = distance * getDeliveryChargePerKm(context);
      }else if(getDeliveryChargeType(context) == DeliveryChargeType.area.name){
        deliveryCharge = getAreaWiseDeliveryCharge(context);
      }
    }

    print("---------------(DELIVERY CHARGE)--------Delivery Charge $deliveryCharge");
    return deliveryCharge;
  }

  static selectDeliveryAddressAuto({AddressModel? lastAddress, required bool isLoggedIn, required String? orderType}) async {
    final AddressProvider locationProvider = Provider.of<AddressProvider>(Get.context!, listen: false);
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(Get.context!, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(Get.context!, listen: false);


    AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
      addressList: locationProvider.addressList,
      selectedAddress: checkoutProvider.orderAddressIndex == -1 ? null : locationProvider.addressList?[checkoutProvider.orderAddressIndex],
      lastOrderAddress: lastAddress,
    );

    print('---------------(2)--------------');
    print('----------------(2) Delivery Address -----${deliveryAddress?.toJson().toString()}');



    if(isLoggedIn && orderType == 'delivery' && deliveryAddress != null && locationProvider.getAddressIndex(deliveryAddress) != null){

      print('--------------(3)---------------');
      if(isSelectDeliveryAddress(deliveryAddress)){
        print('----------(4)-------------');

        await CheckOutHelper.selectDeliveryAddress(Get.context!,
          isAvailable: true,
          index: locationProvider.getAddressIndex(deliveryAddress)!,
          configModel: splashProvider.configModel!,
          fromAddressList: false,
        );
      }

    }

  }

  static bool isSelfPickup({required String? orderType}) => orderType == 'self_pickup';

  static bool isGuestCheckout(BuildContext context){
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final AuthProvider authProvider = context.read<AuthProvider>();
    return (splashProvider.configModel!.isGuestCheckout!) && authProvider.getGuestId() != null;

  }

  static String getDeliveryChargeType(BuildContext context){
    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.deliveryChargeType ?? '';
  }

  static double getMinimumDistanceForFreeDelivery(BuildContext context){
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.minimumDistanceForFreeDelivery?.toDouble() ?? 0.0;
  }

  static double getDeliveryChargePerKm(BuildContext context){
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();

    return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.deliveryChargePerKilometer?.toDouble() ?? 0.0;
  }

  static double getAreaWiseDeliveryCharge(BuildContext context){
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    final OrderProvider orderProvider = context.read<OrderProvider>();

    if(orderProvider.selectedAreaID == null){
      return 0.0;
    }else{
      return splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeByArea?.firstWhere((area) => area.id == orderProvider.selectedAreaID).deliveryCharge?.toDouble() ?? 0.0;
    }

  }

  static bool isSelectDeliveryAddress(AddressModel deliveryAddress){

    bool isSelectDeliveryAddress = false;
    bool hasLatLon = (deliveryAddress.latitude?.isNotEmpty ?? false) && (deliveryAddress.longitude?.isNotEmpty ?? false);
    print('--------------(HAS LAT LON)-------------$hasLatLon');
    if(hasLatLon){
      //isSelectDeliveryAddress = getDeliveryChargeType(Get.context!) == DeliveryChargeType.distance.name;
      isSelectDeliveryAddress = true;
      print("------------(IS SELECTED DELIVERY ADDRESS IF)-----------$isSelectDeliveryAddress");
    }else{
      isSelectDeliveryAddress = !(getDeliveryChargeType(Get.context!) == DeliveryChargeType.distance.name);
      print("------------(IS SELECTED DELIVERY ADDRESS Else)-----------$isSelectDeliveryAddress");
    }

    return isSelectDeliveryAddress;
  }

}