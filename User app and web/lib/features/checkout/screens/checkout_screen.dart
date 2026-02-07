import 'dart:ui';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/check_out_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_web_title_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/not_logged_in_screen.dart';
import 'package:hexacom_user/features/address/providers/address_provider.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/delivery_address_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/details_view_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/map_view_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/place_order_button_view.dart';
import 'package:hexacom_user/features/checkout/widgets/zip_code_view_widget.dart';
import 'package:hexacom_user/features/order/enums/delivery_charge_type.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel>? cartList;
  final double? amount;
  final double? discount;
  final String? couponCode;
  final double deliveryCharge;
  final String? orderType;
  final bool fromCart;

  const CheckoutScreen({
    super.key,
    required this.amount,
    required this.orderType,
    required this.fromCart,
    required this.discount,
    required this.couponCode,
    required this.deliveryCharge, this.cartList,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey dropDownKey = GlobalKey();
  final ScrollController scrollController = ScrollController();

  late bool _isLoggedIn;
  late List<CartModel?> _cartList;
  List<Branches>? _branches = [];


  @override
  void initState() {
    super.initState();

    final CheckoutProvider checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final AuthProvider authProvider = context.read<AuthProvider>();

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    _branches = Provider.of<SplashProvider>(context, listen: false).configModel?.branches;
    orderProvider.setAreaID(isReload: true, isUpdate: false);
    orderProvider.setDeliveryCharge(0, notify: false);




    if(_isLoggedIn || CheckOutHelper.isGuestCheckout(context) ) {

      Provider.of<AddressProvider>(context, listen: false).initAddressList().then((value) {
        CheckOutHelper.selectDeliveryAddressAuto(orderType: widget.orderType, isLoggedIn: _isLoggedIn, lastAddress: null);
      });
      Provider.of<CheckoutProvider>(context, listen: false).clearPrevData();

      _cartList = [];

      if(widget.fromCart) {
        _cartList.addAll(Provider.of<CartProvider>(context, listen: false).cartList);
      }else{
        _cartList.addAll(widget.cartList ?? []);
      }

      if(Provider.of<ProfileProvider>(context, listen: false).userInfoModel == null && authProvider.isLoggedIn()) {
        Provider.of<ProfileProvider>(context, listen: false).getUserInfo();
      }
    }

    checkoutProvider.setCheckOutData = CheckOutModel(
      orderType: widget.orderType,
      deliveryCharge: widget.deliveryCharge,
      freeDeliveryType: '',
      amount: widget.amount,
      placeOrderDiscount: 0,
      couponCode: widget.couponCode, orderNote: null,
      widgetDiscount: widget.discount,
    );

  }

  @override
  Widget build(BuildContext context) {

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();
    bool kmWiseCharge = splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeSetup?.deliveryChargeType == 'distance';
    bool selfPickup = widget.orderType == 'self_pickup';

    print("----------(Guest ID)----${authProvider.getGuestId()}");

    final bool isRoute = (_isLoggedIn || (configModel.isGuestCheckout! && authProvider.getGuestId() != null));

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBarWidget(title: getTranslated('checkout', context)),
      body: isRoute ? Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {

          double deliveryCharge = CheckOutHelper.getDeliveryCharge(
            orderAmount: widget.amount ?? 0.0,
            distance: checkoutProvider.distance,
            discount: widget.discount ?? 0.0,
            freeDeliveryType:  checkoutProvider.getCheckOutData?.freeDeliveryType,
            configModel: configModel,
            context: context,
            isSelfPickUp: widget.orderType == 'self_pickup'
          );
          orderProvider.setDeliveryCharge(deliveryCharge, notify: false);

          return Consumer<AddressProvider>(builder: (context, address, child) {
            return Column(children: [

              Expanded(child: CustomScrollView(controller: scrollController, slivers: [
                SliverToBoxAdapter(child: Center(child: SizedBox(width: Dimensions.webScreenWidth,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    CustomWebTitleWidget(title: getTranslated('checkout', context)),

                    if(!ResponsiveHelper.isDesktop(context))
                      MapViewWidget(isSelfPickUp: selfPickup),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    //Zip/Area
                    if(!ResponsiveHelper.isDesktop(context) && CheckOutHelper.getDeliveryChargeType(context) == DeliveryChargeType.area.name && !selfPickup)...[
                      ZipCodeViewWidget(
                        dropDownKey: dropDownKey,
                        discount: widget.discount ?? 0.0,
                        amount: widget.amount ?? 0.0,
                        isSelfPickUp: selfPickup,
                      ),
                    ],

                    if(!ResponsiveHelper.isDesktop(context))...[
                      DeliveryAddressWidget(selfPickup: selfPickup),
                    ],

                    if(!ResponsiveHelper.isDesktop(context)) Selector<OrderProvider, double?>(
                      selector: (context, orderProvider) => orderProvider.deliveryCharge,
                      builder: (context, deliveryCharge, child) {
                        return DetailsViewWidget(
                          amount: widget.amount ?? 0,
                          kmWiseCharge: kmWiseCharge,
                          selfPickup: selfPickup,
                          deliveryCharge: orderProvider.deliveryCharge ?? 0.0,
                          orderNoteController: _noteController,
                          orderType: widget.orderType,
                          cartList: _cartList,
                        );
                      }
                    ),

                    if(ResponsiveHelper.isDesktop(context)) Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Expanded(flex: 6, child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color:Theme.of(context).shadowColor, blurRadius: 10),
                              ],
                            ),
                            child: MapViewWidget(
                              isSelfPickUp: selfPickup,
                              dropDownKey: dropDownKey,
                              discount: widget.discount ?? 0.0,
                              amount: widget.amount ?? 0.0,
                            ),
                          )),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Expanded(flex: 3, child: Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color:Theme.of(context).shadowColor, blurRadius: 10),
                            ],
                          ),
                          child: DetailsViewWidget(
                            amount: widget.amount ?? 0,
                            kmWiseCharge: kmWiseCharge,
                            selfPickup: selfPickup,
                            deliveryCharge: orderProvider.deliveryCharge ?? 0.0,
                            orderNoteController: _noteController,
                            orderType: widget.orderType ?? '',
                            cartList: _cartList,
                            scrollController: scrollController,
                            dropdownKey: dropDownKey,
                          ),
                        )),

                      ]),
                    ),

                  ]),
                ))),

                const FooterWebWidget(footerType: FooterType.sliver),


              ])),

              if(!ResponsiveHelper.isDesktop(context)) PlaceOrderButtonView(
                deliveryCharge: orderProvider.deliveryCharge,
                amount: widget.amount,
                cartList: _cartList,
                kmWiseCharge: kmWiseCharge,
                orderNote: _noteController.text,
                orderType: widget.orderType,
                scrollController: scrollController,
                dropdownKey: dropDownKey,
              ),

            ]);

            },
          );
        },
      ) : const NotLoggedInScreen(),
    );
  }




  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

}








