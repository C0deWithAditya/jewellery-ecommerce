import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/checkout/widgets/payment_button_widget.dart';
import 'package:hexacom_user/features/checkout/widgets/payment_method_widget.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';



class PaymentMethodBottomSheetWidget extends StatefulWidget {

  const PaymentMethodBottomSheetWidget({Key? key}) : super(key: key);

  @override
  State<PaymentMethodBottomSheetWidget> createState() => _PaymentMethodBottomSheetWidgetState();
}

class _PaymentMethodBottomSheetWidgetState extends State<PaymentMethodBottomSheetWidget> {
  bool notHideCod = true;
  bool notHideDigital = true;
  List<PaymentMethod> paymentList = [];

  @override
  void initState() {
    super.initState();

    final CheckoutProvider checkoutProvider =  Provider.of<CheckoutProvider>(context, listen: false);
    final SplashProvider splashProvider =  Provider.of<SplashProvider>(context, listen: false);

    final ConfigModel configModel = splashProvider.configModel!;

    checkoutProvider.setPaymentIndex(null, isUpdate: false);




    if(notHideDigital) {
      paymentList.addAll(configModel.activePaymentMethodList ?? []);
    }

  }
  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    final bool isCODActive = configModel.cashOnDelivery!;


    final bool isDisableAllPayment = !isCODActive &&  paymentList.isEmpty;

    return SingleChildScrollView(
      child: Center(child: SizedBox(width: 550, child: Column(mainAxisSize: MainAxisSize.min, children: [
        if(ResponsiveHelper.isDesktop(context)) SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

        if(ResponsiveHelper.isDesktop(context)) Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 30, width: 30,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.clear),
            ),
          ),
        ),

        Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
          width: 550,
          margin: const EdgeInsets.only(top: kIsWeb ? 0 : 30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: ResponsiveHelper.isMobile(context) ?  const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSizeDefault))
                : const BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
          child: isDisableAllPayment ? Text(getTranslated('no_payment_methods_are_available', context)) :  Consumer<CheckoutProvider>(
              builder: (ctx, checkoutProvider, _) {

                return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  !ResponsiveHelper.isDesktop(context) ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 4, width: 35,
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                    ),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Row(children: [
                    notHideCod ? Text(getTranslated('choose_payment_method', context), style: rubikBold.copyWith(fontSize: Dimensions.fontSizeDefault)) : const SizedBox(),
                    SizedBox(width: notHideCod ? Dimensions.paddingSizeExtraSmall : 0),
                  ]),


                  SizedBox(height: notHideCod ? Dimensions.paddingSizeLarge : 0),

                  Row(children: [
                    if(isCODActive) Expanded(
                      child: PaymentButtonWidget(
                        icon: Images.cashOnDelivery,
                        title: getTranslated('cash_on_delivery', context),
                        isSelected: checkoutProvider.paymentMethodIndex == 0,
                        onTap: () {
                         checkoutProvider.setPaymentIndex(0);
                        },
                      ),
                    ),

                    if(isCODActive) const SizedBox(width: Dimensions.paddingSizeLarge),


                  ]),

                 if(paymentList.isNotEmpty) Row(children: [
                    Text(getTranslated('pay_via_online', context), style: rubikBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Flexible(child: Text('(${getTranslated('faster_and_secure_way_to_pay_bill', context)})', style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ))),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                 if(paymentList.isNotEmpty) Expanded(child: PaymentMethodWidget(
                    paymentList: paymentList,
                    onTap: (index)=> checkoutProvider.changePaymentMethod(digitalMethod: paymentList[index]),
                  )),
                  const SizedBox(height: Dimensions.paddingSizeSmall),


                  SafeArea(child: CustomButtonWidget(
                    btnTxt: getTranslated('select', context),
                    onTap: checkoutProvider.paymentMethodIndex == null
                        && checkoutProvider.paymentMethod == null
                        ? null : () {

                      Navigator.pop(context);

                      checkoutProvider.savePaymentMethod(index: checkoutProvider.paymentMethodIndex, method: checkoutProvider.paymentMethod);

                    },
                  )),

                ]);
              }
          ),
        ),
      ]))),
    );
  }
}


