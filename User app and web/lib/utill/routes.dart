import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/enums/html_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/notification_body.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/common/models/place_order_model.dart';
import 'package:hexacom_user/common/models/address_model.dart';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/common/widgets/map_widget.dart';
import 'package:hexacom_user/common/widgets/not_found.dart';
import 'package:hexacom_user/features/address/screens/add_new_address_screen.dart';
import 'package:hexacom_user/features/address/screens/address_screen.dart';
import 'package:hexacom_user/features/auth/screens/create_account_screen.dart';
import 'package:hexacom_user/features/auth/screens/login_screen.dart';
import 'package:hexacom_user/features/auth/screens/otp_registration_screen.dart';
import 'package:hexacom_user/features/auth/screens/send_otp_screen.dart';
import 'package:hexacom_user/features/category/screens/all_category_screen.dart';
import 'package:hexacom_user/features/category/screens/category_screen.dart';
import 'package:hexacom_user/features/chat/screens/chat_screen.dart';
import 'package:hexacom_user/features/checkout/screens/checkout_screen.dart';
import 'package:hexacom_user/features/coupon/screens/coupon_screen.dart';
import 'package:hexacom_user/features/dashboard/screens/dashboard_screen.dart';
import 'package:hexacom_user/features/flash_sale/screens/flash_sale_details_screen.dart';
import 'package:hexacom_user/features/forgot_password/screens/create_new_password_screen.dart';
import 'package:hexacom_user/features/forgot_password/screens/forgot_password_screen.dart';
import 'package:hexacom_user/features/forgot_password/screens/verification_screen.dart';
import 'package:hexacom_user/features/html/screens/html_viewer_screen.dart';
import 'package:hexacom_user/features/language/screens/choose_language_screen.dart';
import 'package:hexacom_user/features/maintanance/screens/maintainance_screen.dart';
import 'package:hexacom_user/features/notification/screens/notification_screen.dart';
import 'package:hexacom_user/features/onboarding/screens/onboarding_screen.dart';
import 'package:hexacom_user/features/order/screens/order_details_screen.dart';
import 'package:hexacom_user/features/order/screens/order_screen.dart';
import 'package:hexacom_user/features/order/screens/order_search_screen.dart';
import 'package:hexacom_user/features/order/screens/order_successful_screen.dart';
import 'package:hexacom_user/features/order/screens/track_order_screen.dart';
import 'package:hexacom_user/features/payment/screens/order_web_payment.dart';
import 'package:hexacom_user/features/payment/screens/payment_screen.dart';
import 'package:hexacom_user/features/product/screens/product_details_screen.dart';
import 'package:hexacom_user/features/product/screens/product_image_screen.dart';
import 'package:hexacom_user/features/profile/screens/profile_screen.dart';
import 'package:hexacom_user/features/rate_review/screens/rate_review_screen.dart';
import 'package:hexacom_user/features/search/screens/search_result_screen.dart';
import 'package:hexacom_user/features/search/screens/search_screen.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/splash/screens/splash_screen.dart';
import 'package:hexacom_user/features/support/screens/support_screen.dart';
import 'package:hexacom_user/features/update/screens/update_screen.dart';
import 'package:hexacom_user/features/welcome_screen/screens/welcome_screen.dart';
import 'package:hexacom_user/helper/maintenance_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/main.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

enum RouteAction{push, pushReplacement, popAndPush, pushNamedAndRemoveUntil}

class RouteHelper {

  static const String splashScreen = '/splash';
  static const String languageScreen = '/select-language';
  static const String onBoardingScreen = '/onboarding';
  static const String welcomeScreen = '/welcome';
  static const String loginScreen = '/login';
  static const String verify = '/verify';
  static const String forgotPassScreen = '/forgot-password';
  static const String createNewPassScreen = '/create-new-password';
  static const String createAccountScreen = '/create-account';
  static const String dashboard = '/';
  static const String maintain = '/maintain';
  static const String update = '/update';
  static const String dashboardScreen = '/main';
  static const String searchScreen = '/search';
  static const String searchResultScreen = '/search-result';
  static const String categoryScreen = '/category-screen';
  static const String notificationScreen = '/notification';
  static const String checkoutScreen = '/checkout';
  static const String paymentScreen = '/payment';
  static const String orderSuccessScreen = '/order-completed';
  static const String orderDetailsScreen = '/order-details';
  static const String rateScreen = '/rate-review';
  static const String trackOrder =  '/track-order';
  static const String profileScreen = '/profile';
  static const String addressScreen = '/address';
  static const String mapScreen = '/map';
  static const String addAddressScreen = '/add-address';
  static const String selectLocationScreen = '/select-location';
  static const String chatScreen = '/chat_screen';
  static const String couponScreen = '/coupons';
  static const String supportScreen = '/support';
  static const String termsScreen = '/terms';
  static const String policyScreen = '/privacy-policy';
  static const String aboutUsScreen = '/about-us';
  static const String productDetails = '/product-details';
  static String productImages = '/product-images';
  static const String returnPolicyScreen = '/return-policy';
  static const String refundPolicyScreen = '/refund-policy';
  static const String cancellationPolicyScreen = '/cancellation-policy';
  static String categories = '/categories';
  static const String flashSaleDetailsScreen = '/flash-sale-details';
  static const String orderWebPayment = '/order-web-payment';
  static const String orderListScreen = '/order-list';
  static const String orderSearchScreen = '/order-search';
  static const String sendOtp = '/send-otp-verification';
  static const String otpRegistration = '/otp-registration';

  static HistoryUrlStrategy historyUrlStrategy = HistoryUrlStrategy();


  static String getSplashRoute(BuildContext? context, {NotificationBody? body,RouteAction? action}) {
    String data = 'null';
    if(body != null) {
      List<int> encoded = utf8.encode(jsonEncode(body));
      data = base64Encode(encoded);
    }
    return _navigateRoute(context, '$splashScreen?data=$data', route: action);
  }
  static String getLanguageRoute(BuildContext context, String page, {RouteAction? action}) => _navigateRoute(context, '$languageScreen?page=$page', route: action);
  static String getOnBoardingRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, onBoardingScreen, route: action);
  static String getWelcomeRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, welcomeScreen, route: action);
  static String getLoginRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, loginScreen, route: action);
  static String getForgetPassRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, forgotPassScreen, route: action);
  static String getNewPassRoute(BuildContext context, String userInput, String token, {RouteAction? action}) => _navigateRoute(context, '$createNewPassScreen?userInput=$userInput&token=$token', route: action);
  static String getVerifyRoute(BuildContext context, String userInput, String fromPage,  {String? session, RouteAction? action}) {
    print("-------(GET VERIFY)---------$userInput and $fromPage");

    String data = Uri.encodeComponent(jsonEncode(userInput));
    String authSession = base64Url.encode(utf8.encode(session ?? ''));
    return _navigateRoute(context, '$verify?page=$fromPage&userInput=$data&data=$authSession', route: action);
  }
  static String getCreateAccountRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, createAccountScreen, route: action);
  static String getMainRoute(BuildContext? context, {RouteAction? action}) => _navigateRoute(context, dashboard, route: action);
  static String getMaintainRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, maintain, route: action);
  static String getSendOtpScreen(BuildContext context, {RouteAction? action}) => _navigateRoute(context, sendOtp, route: action);
  static String getUpdateRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, update, route: action);
  static String getDashboardRoute(BuildContext context, String page, {RouteAction? action}) => _navigateRoute(context, '$dashboardScreen?page=$page', route: action);
  static String getProductDetailsRoute(BuildContext context, int? id, {RouteAction? action}) => _navigateRoute(context, '$productDetails?id=$id', route: action);
  static String getProductImageRoute(BuildContext context, String images, {RouteAction? action}) => _navigateRoute(context, '$productImages?images=$images', route: action);
  static String getSearchRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, searchScreen, route: action);
  static String getSearchResultRoute(BuildContext context, {SearchShortBy? shortBy, String? text, RouteAction? action}) {
    String data = '';
    if(text?.isNotEmpty ?? false){
      List<int> encoded = utf8.encode(jsonEncode(text ?? ''));
      data = base64Encode(encoded);
    }
    return _navigateRoute(context, '$searchResultScreen?text=$data&short_by=${shortBy != null ? shortBy.name : ''}', route: action);
  }
  static String getNotificationRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, notificationScreen, route: action);
  static String getCategoryRoute(BuildContext context, CategoryModel? categoryModel,{int? subCategoryId, RouteAction? action}) {
    return _navigateRoute(context, '$categoryScreen?sub_id=${subCategoryId ?? '-1'}&id=${categoryModel?.id}', route: action);
  }

  static String getCheckoutRoute(BuildContext context, {
    required double amount,
    double? discount, String? type, String? code,
    required double deliveryCharge,
    bool? fromCart = true,
    RouteAction? action,
  }){
    String amountData = base64Encode(utf8.encode('$amount'));
    String discountData = base64Encode(utf8.encode('$discount'));
    String deliveryChargeData = base64Encode(utf8.encode('$deliveryCharge'));
    String couponData = base64Encode(utf8.encode('$code'));
    String isFromCart = fromCart! ? '1' : '0';
    return _navigateRoute(context, '$checkoutScreen?amount=$amountData&discount=$discountData&type=$type&code=$couponData&del_char=$deliveryChargeData&fr_cart=$isFromCart', route: action);

  }

  static String getPaymentRoute(BuildContext context, {String? id = '', String? url, PlaceOrderModel? placeOrderBody, RouteAction? action}) {
    String uri = url != null ? Uri.encodeComponent(base64Encode(utf8.encode(url))) : 'null';
    String data = placeOrderBody != null ? base64Url.encode(utf8.encode(jsonEncode(placeOrderBody.toJson()))) : '';
    return _navigateRoute(context, '$paymentScreen?id=$id&uri=$uri&place_order=$data', route: action);
  }

  static String getOrderDetailsRoute(BuildContext context, int? id, OrderModel? orderModel, {bool? isFromTrackOrderPage, String? userPhoneNumber, RouteAction? action}) {
    String isFromTrack = (isFromTrackOrderPage ?? false) ? '1' : '0';
    String? order = (orderModel != null) ? base64Url.encode(utf8.encode(jsonEncode(orderModel.toJson()))) : null;
    return _navigateRoute(context, '$orderDetailsScreen?id=$id&order=$order&trackOrderPage=$isFromTrack&phone=$userPhoneNumber', route: action);
  }
  static String getRateReviewRoute(BuildContext context, String orderId, DeliveryMan deliveryMan, List<OrderDetailsModel>? orderDetailsList, {RouteAction? action}){
    String delivery = base64Url.encode(utf8.encode(jsonEncode(deliveryMan.toJson())));
    String orderDetails = base64Url.encode(utf8.encode(jsonEncode(orderDetailsList?.map((e) => e.toJson()).toList() ?? [])));
    return _navigateRoute(context, '$rateScreen?orderId=$orderId&delivery=$delivery&orderDetails=$orderDetails', route: action);
  }
  static String getOrderTrackingRoute(BuildContext context, int? id, String? phoneNumber, {RouteAction? action}) => _navigateRoute(context, '$trackOrder?id=$id&phone=${Uri.encodeComponent('$phoneNumber')}', route: action);
  static String getProfileRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, profileScreen, route: action);
  static String getAddressRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, addressScreen, route: action);
  static String getMapRoute(BuildContext context, AddressModel addressModel, {RouteAction? action}) {
    List<int> encoded = utf8.encode(jsonEncode(addressModel.toJson()));
    String data = base64Encode(encoded);
    return _navigateRoute(context, '$mapScreen?address=$data', route: action);
  }
  static String getAddAddressRoute(BuildContext context, String page, String action, AddressModel addressModel, {RouteAction? routeAction}) {
    String data = base64Url.encode(utf8.encode(jsonEncode(addressModel.toJson())));
    return _navigateRoute(context, '$addAddressScreen?page=$page&action=$action&address=$data', route: routeAction);
  }
  static String getSelectLocationRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, selectLocationScreen, route: action);
  static String getChatRoute(BuildContext context, {int? orderId, String? userName, String? profileImage, RouteAction? action}) {
    return _navigateRoute(context, '$chatScreen?id=$orderId&name=$userName&image=$profileImage', route: action);
  }
  static String getCouponRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, couponScreen, route: action);
  static String getSupportRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, supportScreen, route: action);
  static String getTermsRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, termsScreen, route: action);
  static String getPolicyRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, policyScreen, route: action);
  static String getAboutUsRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, aboutUsScreen, route: action);
  static String getReturnPolicyRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, returnPolicyScreen, route: action);
  static String getCancellationPolicyRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, cancellationPolicyScreen, route: action);
  static String getRefundPolicyRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, refundPolicyScreen, route: action);
  static String getCategoryAllRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, categories, route: action);
  static String getFlashSaleDetailsRoute(BuildContext context, {RouteAction? action}) => _navigateRoute(context, flashSaleDetailsScreen, route: action);
  static String getOrderListScreen(BuildContext context, {RouteAction? action}) => _navigateRoute(context, orderListScreen, route: action);
  static String getOrderSearchScreen(BuildContext context, {RouteAction? action}) => _navigateRoute(context, orderSearchScreen, route: action);
  static String getOrderSuccessScreen(BuildContext context, String orderId, String status, {RouteAction? action}) => _navigateRoute(context,
    "$orderSuccessScreen?id=$orderId&status=$status", route: action,
  );
  static String getOtpRegistrationScreen(BuildContext context, String? tempToken, String userInput, {String? userName, RouteAction action = RouteAction.pushNamedAndRemoveUntil}){
    String data = '';
    if(tempToken != null && tempToken.isNotEmpty){
      data = Uri.encodeComponent(jsonEncode(tempToken));
    }
    String input = Uri.encodeComponent(jsonEncode(userInput));
    String name = '';
    name = Uri.encodeComponent(jsonEncode(userName ?? ''));
    return _navigateRoute(context, '$otpRegistration?tempToken=$data&input=$input&userName=$name', route: action);

  }


  static String _navigateRoute(BuildContext? context, String path,{RouteAction? route = RouteAction.push}) {

    if(kIsWeb){
      if(route == RouteAction.pushNamedAndRemoveUntil){
        if(context == null){
          Get.context?.go(path);
        }else{
          GoRouter.of(context).go(path);
          print('-------------(PATH WEB PUSH REMOVE)------$path and $route');
        }
        if(kIsWeb) {
          historyUrlStrategy.replaceState(null, '', '/');
        }

      }else if(route == RouteAction.pushReplacement){

        if(context == null){
          Get.context?.pushReplacement(path);
        }else{
          GoRouter.of(context).pushReplacement(path);
          print('-------------(PATH WEB REPLACEMENT)------$path and $route');
        }

      }else{
        if(context == null){
          Get.context?.push(path);
        }else{
          GoRouter.of(context).push(path);
          print('-------------(PATH WEB PUSH)------$path and $route');
        }


      }
    }else{
      if(route == RouteAction.pushNamedAndRemoveUntil){
        print('-------------(PATH)------$path and $route');
        Get.context?.go(path);
      }else if(route == RouteAction.pushReplacement){
        print('-------------(PATH)------$path and $route');
        Get.context?.pushReplacement(path);

      }else{
        print('-------------(PATH)------$path and $route');
        Get.context?.push(path);
      }
    }

    return path;
  }

  static  Widget _routeHandler(BuildContext context, Widget route,  {required String? path}) {

    final SplashProvider splashProvider = context.read<SplashProvider>();

    return splashProvider.configModel == null
        ? const SplashScreen() : _isMaintenance(splashProvider.configModel!)
        ? const MaintenanceScreen() : route;

  }

  static _isMaintenance(ConfigModel configModel) {
    if(MaintenanceHelper.isMaintenanceModeEnable(configModel)){
      if(MaintenanceHelper.checkWebMaintenanceMode(configModel) || MaintenanceHelper.checkCustomerMaintenanceMode(configModel)){
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
  }

  static String? _getPath(GoRouterState state) {
    print('----------------(STATE)------------------------${state.fullPath}?${state.uri.query}');
    return '${state.fullPath}?${state.uri.query}';
  }

  static final  goRoutes = GoRouter(
    navigatorKey: navigatorKey,

    initialLocation: ResponsiveHelper.isMobilePhone() ? getSplashRoute(Get.context) : getMainRoute(Get.context),
    errorBuilder: (ctx, _)=> const NotFound(),
    routes: [
      GoRoute(path: splashScreen, builder: (context, state) {
        // NotificationBody? data;
        // if(state.uri.queryParameters['data'] != 'null') {
        //   List<int> decode = base64Decode(state.uri.queryParameters['data']!.replaceAll(' ', '+'));
        //   data = NotificationBody.fromJson(jsonDecode(utf8.decode(decode)));
        // }
        return _routeHandler(context, const SplashScreen(), path: _getPath(state));
      }),
      GoRoute(path: languageScreen, builder: (context, state) => _routeHandler(context,
          ChooseLanguageScreen(fromMenu: state.uri.queryParameters['page'] == 'menu'), path: _getPath(state))
      ),
      GoRoute(path: onBoardingScreen, builder: (context, state) => _routeHandler(context, OnBoardingScreen(), path: _getPath(state))),
      GoRoute(path: welcomeScreen, builder: (context, state) => _routeHandler(context, const WelcomeScreen(), path: _getPath(state))),
      GoRoute(path: loginScreen, builder: (context, state) => _routeHandler(context, const LoginScreen(), path: _getPath(state))),
      GoRoute(path: forgotPassScreen, builder: (context, state) => _routeHandler(context, const ForgotPasswordScreen(), path: _getPath(state))),

      GoRoute(path: createNewPassScreen, builder: (context, state) => _routeHandler(context, path: _getPath(state), CreateNewPasswordScreen(
        userInput: Uri.decodeComponent(state.uri.queryParameters['userInput'] ?? ''),
        resetToken: state.uri.queryParameters['token'],
      ))),
      GoRoute(path: orderWebPayment, builder: (context, state) =>  _routeHandler(context, path: _getPath(state), OrderWebPayment(token: state.uri.queryParameters['token']))),

      GoRoute(path: verify, builder: (context, state) {
        print("----------(FROMPAGE IN VERIFY)-----------${state.uri.queryParameters['fromPage']}");

        return _routeHandler(context,  VerificationScreen(
          userInput: jsonDecode(state.uri.queryParameters['userInput'] ?? ''),
          fromPage: state.uri.queryParameters['page'] ?? '',
          session: state.uri.queryParameters['data'] == 'null'
              ? null
              : utf8.decode(base64Url.decode(state.uri.queryParameters['data'] ?? '')),
        ), path: _getPath(state));
      }),
      GoRoute(path: createAccountScreen, builder: (context, state) => _routeHandler(context, const CreateAccountScreen(), path: _getPath(state))),
      GoRoute(path: dashboard, builder: (context, state) => _routeHandler(context, const DashboardScreen(pageIndex: 0), path: _getPath(state))),
      GoRoute(path: maintain, builder: (context, state) => _routeHandler(context, const MaintenanceScreen(), path: _getPath(state))),

      GoRoute(path: dashboardScreen, builder: (context, state) {
        return _routeHandler(context, DashboardScreen(
          pageIndex: state.uri.queryParameters['page'] == 'home'
              ? 0 : state.uri.queryParameters['page'] == 'cart'
              ? 1 : state.uri.queryParameters['page'] == 'favourite'
              ? 2 : state.uri.queryParameters['page'] == 'menu'
              ? 3  : 0,
        ),path: _getPath(state));
      }),
      GoRoute(path: update, builder: (context, state) => _routeHandler(context, const UpdateScreen(), path: _getPath(state))),

      GoRoute(path: productDetails, builder: (context, state) {
        return _routeHandler(context, ProductDetailsScreen(
          product: Product(id: int.parse(state.uri.queryParameters['id']!)),
        ),path: _getPath(state));
      }),

      GoRoute(path: productImages, builder: (context, state) {

        print('-------------(PRODUCT IMAGES)---------------${state.uri.queryParameters['images']}');

        return _routeHandler(context, ProductImageScreen(
          imageList: jsonDecode(state.uri.queryParameters['images']!),
        ),path: _getPath(state));
      }),
      GoRoute(path: searchScreen, builder: (context, state) => _routeHandler(context, const SearchScreen(), path: _getPath(state))),

      GoRoute(path: searchResultScreen, builder: (context, state) {

        String data = '';
        if(state.uri.queryParameters['text']?.isNotEmpty ?? false){
          try {
            List<int> decodedBytes = base64Decode(state.uri.queryParameters['text']!);
            data = jsonDecode(utf8.decode(decodedBytes));  // Decode bytes to string
          } catch (e) {}
        }

        String? shortBy = state.uri.queryParameters['short_by'];

        return _routeHandler(context,
          SearchResultScreen(
            searchString: data,
            shortBy: (shortBy?.isEmpty ?? false) || shortBy == 'null' ? null : SearchShortBy.values.byName(shortBy!),
          ), path: _getPath(state),
        );
      }),
      GoRoute(path: notificationScreen, builder: (context, state) => _routeHandler(context, const NotificationScreen(), path: _getPath(state))),
      GoRoute(path: categoryScreen,  builder: (context, state) {

        return _routeHandler(context, CategoryScreen(
          categoryId: int.parse(state.uri.queryParameters['id']!),
          subCategoryId: '${state.uri.queryParameters['sub_id']}' == '-1' ? null : int.tryParse(state.uri.queryParameters['sub_id']!),
        ), path: _getPath(state));
      }),

      GoRoute(path: checkoutScreen, builder: (context, state){
        return _routeHandler(context, CheckoutScreen(
            amount: double.parse(utf8.decode(base64Decode(state.uri.queryParameters['amount']!))),
            orderType: state.uri.queryParameters['type'],
            fromCart: state.uri.queryParameters['fr_cart']!.contains('1'),
            discount: double.parse(utf8.decode(base64Decode(state.uri.queryParameters['discount']!))),
            couponCode: utf8.decode(base64Decode(state.uri.queryParameters['code']!)),
            deliveryCharge: double.parse(utf8.decode(base64Decode(state.uri.queryParameters['del_char']!)))
        ), path: _getPath(state));
      }),

      GoRoute(path: paymentScreen, builder: (context, state)=> _routeHandler(context,
          PaymentScreen(
              url: Uri.decodeComponent(utf8.decode(base64Decode(state.uri.queryParameters['uri']!))),
              orderId: int.tryParse(state.uri.queryParameters['id']!)
          ), path: _getPath(state)
      )),

      GoRoute(path: orderDetailsScreen, builder: (context, state) {

        int? orderId = int.tryParse(state.uri.queryParameters['id'] ?? '');
        OrderModel? order = state.uri.queryParameters['order'] != "null"
            ? OrderModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(state.uri.queryParameters['order']!))))
            : null;

        return _routeHandler(context,
          OrderDetailsScreen(orderId: orderId, orderModel: order,
            isFromTrackOrderPage: state.uri.queryParameters['trackOrderPage']!.contains('1'),
            userPhoneNumber: state.uri.queryParameters['phone'],
          ),
          path: _getPath(state),
        );
      }),


      GoRoute(
        path: rateScreen,
        builder: (context, state) {
          String orderId = state.uri.queryParameters['orderId'] ?? '';
          DeliveryMan deliveryMan = DeliveryMan.fromJson(jsonDecode(utf8.decode(base64Url.decode(state.uri.queryParameters['delivery'] ?? ''))));
          List<OrderDetailsModel> orderDetailsList = (jsonDecode(utf8.decode(base64Url.decode(state.uri.queryParameters['orderDetails'] ?? ''))) as List)
              .map((e) => OrderDetailsModel.fromJson(e))
              .toList();

          return _routeHandler(
            context,
            RateReviewScreen(orderId: int.tryParse(orderId), deliveryMan: deliveryMan, orderDetailsList: orderDetailsList),
            path: _getPath(state),
          );
        },
      ),


      GoRoute(path: trackOrder, builder: (context, state) => _routeHandler(context,
        TrackOrderScreen(
          orderID: state.uri.queryParameters['id'],
          phone: Uri.decodeComponent(state.uri.queryParameters['phone'] ?? ""),
        ), path: _getPath(state),
      )),
      GoRoute(path: profileScreen, builder: (context, state) => _routeHandler(context, const ProfileScreen(), path: _getPath(state))),
      GoRoute(path: addressScreen, builder: (context, state) => _routeHandler(context, const AddressScreen(), path: _getPath(state))),
      GoRoute(path: mapScreen, builder: (context, state) {
        List<int> decode = base64Decode('${state.uri.queryParameters['address']?.replaceAll(' ', '+')}');
        DeliveryAddress data = DeliveryAddress.fromJson(jsonDecode(utf8.decode(decode)));
        return _routeHandler(context, MapWidget(address: data), path: _getPath(state));
      }),
      GoRoute(path: addAddressScreen, builder: (context, state) {
        bool isUpdate = state.uri.queryParameters['action'] == 'update';
        AddressModel? addressModel;

        if(isUpdate) {
          String decoded = utf8.decode(base64Url.decode('${state.uri.queryParameters['address']?.replaceAll(' ', '+')}'));
          addressModel = AddressModel.fromJson(jsonDecode(decoded));
        }
        return _routeHandler(context,
          AddNewAddressScreen(
            fromCheckout: state.uri.queryParameters['page'] == 'checkout',
            isUpdateEnable: isUpdate,
            address: isUpdate ? addressModel : null,
          ), path: _getPath(state),
        );
      }),

      GoRoute(path: chatScreen, builder: (context, state) {

        return _routeHandler(context,
          ChatScreen(
            orderId : int.tryParse(state.uri.queryParameters['id'] ?? ""),
            profileImage: state.uri.queryParameters['image'],
            userName: state.uri.queryParameters['name'],
          ),
          path: _getPath(state),
        );
      }),
      GoRoute(path: couponScreen, builder: (context, state) => _routeHandler(context, const CouponScreen(), path: _getPath(state))),
      GoRoute(path: supportScreen, builder: (context, state) => _routeHandler(context, const SupportScreen(), path: _getPath(state))),
      GoRoute(path: termsScreen, builder: (context, state) => _routeHandler(context, const HtmlViewerScreen (htmlType: HtmlType.termsAndCondition), path: _getPath(state))),
      GoRoute(path: policyScreen, builder: (context, state) => _routeHandler(context, const HtmlViewerScreen (htmlType: HtmlType.privacyPolicy), path: _getPath(state))),
      GoRoute(path: aboutUsScreen, builder: (context, state) => _routeHandler(context, const HtmlViewerScreen(htmlType: HtmlType.aboutUs), path: _getPath(state))),
      GoRoute(path: returnPolicyScreen, builder: (context, state) => _routeHandler(context, const HtmlViewerScreen(htmlType: HtmlType.returnPolicy), path: _getPath(state))),
      GoRoute(path: cancellationPolicyScreen, builder: (context, state) => _routeHandler(context, const HtmlViewerScreen(htmlType: HtmlType.cancellationPolicy), path: _getPath(state))),
      GoRoute(path: refundPolicyScreen, builder: (context, state) => _routeHandler(context, const HtmlViewerScreen(htmlType: HtmlType.refundPolicy), path: _getPath(state))),
      GoRoute(path: categories, builder: (context, state) => _routeHandler(context, const AllCategoryScreen(), path: _getPath(state))),
      GoRoute(path: flashSaleDetailsScreen, builder: (context, state) => _routeHandler(context, const FlashSaleDetailsScreen(), path: _getPath(state))),
      GoRoute(path: orderListScreen, builder: (context, state) => _routeHandler(context, const OrderScreen(), path: _getPath(state))),
      GoRoute(path: orderSearchScreen, builder: (context, state) => _routeHandler(context, const OrderSearchScreen(), path: _getPath(state))),
      GoRoute(path: orderSuccessScreen, builder: (context, state) => _routeHandler(context,  OrderSuccessfulScreen(
        orderID: state.uri.queryParameters['id'], status: state.uri.queryParameters['status'] == "success" ? 0 : 1), path: _getPath(state))
      ),
      GoRoute(path: sendOtp, builder: (context, state) => _routeHandler(context, const SendOtpScreen(), path: _getPath(state))),
      GoRoute(path: otpRegistration, builder: (context, state) {
        return _routeHandler(context, OtpRegistrationScreen(
          tempToken: jsonDecode(state.uri.queryParameters['tempToken'] ?? ''),
          userInput: jsonDecode(state.uri.queryParameters['input'] ?? ''),
          userName: jsonDecode(state.uri.queryParameters['userName'] ?? ''),
        ), path: _getPath(state));
      }),

    ],
  );

}


class HistoryUrlStrategy extends PathUrlStrategy {
  @override
  void pushState(Object? state, String title, String url) => replaceState(state, title, url);
}