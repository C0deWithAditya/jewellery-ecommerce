import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/delivery_info_model.dart';
import 'package:hexacom_user/features/checkout/providers/checkout_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/checkout_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class ZipCodeViewWidget extends StatefulWidget {
  final GlobalKey dropDownKey;
  final double discount;
  final double amount;
  final bool isSelfPickUp;
  const ZipCodeViewWidget({super.key, required this.dropDownKey, required this.discount, required this.amount, required this.isSelfPickUp});

  @override
  State<ZipCodeViewWidget> createState() => _ZipCodeViewWidgetState();
}

class _ZipCodeViewWidgetState extends State<ZipCodeViewWidget> {

  final TextEditingController searchController = TextEditingController();
  double deliveryCharge = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Text(getTranslated('zip_area', context),
          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Selector<OrderProvider, int?>(
          selector: (context, orderProvider) => orderProvider.selectedAreaID,
          builder: (context, selectedAreaID, child) {

            final CheckoutProvider checkoutProvider = context.read<CheckoutProvider>();
            final OrderProvider orderProvider = context.read<OrderProvider>();
            final ConfigModel configModel = context.read<SplashProvider>().configModel!;

            return Consumer<SplashProvider>(builder: (context, splashProvider, child) {
              return Row(children: [

                Expanded(child: DropdownButtonHideUnderline(child: DropdownButton2<String>(
                  key: widget.dropDownKey,
                  iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).hintColor)),
                  isExpanded: true,
                  hint: Text(
                    getTranslated('search_or_select_zip_code_area', context),
                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                  ),

                  selectedItemBuilder: (BuildContext context) {
                    return (splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeByArea ?? []).map<Widget>((DeliveryChargeByArea item) {
                      return Row(children: [

                        Text(item.areaName ?? "",
                          style: rubikSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),

                        Text(" (\$${item.deliveryCharge ?? 0})",
                          style: rubikRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).hintColor,
                          ),
                        ),

                      ]);
                    }).toList();
                  },

                  items: (splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeByArea ?? [])
                      .map((DeliveryChargeByArea item) => DropdownMenuItem<String>(

                    value: item.id.toString(),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      Text(item.areaName ?? "", style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      )),

                      Text(" (\$${item.deliveryCharge ?? 0})",
                        style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor,
                        ),
                      ),

                    ]),

                  )).toList(),

                  value: selectedAreaID == null ? null
                      : splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeByArea!.firstWhere((area) => area.id == selectedAreaID).id.toString(),

                  onChanged: (String? value) {
                    orderProvider.setAreaID(areaID: int.parse(value!));
                    deliveryCharge = CheckOutHelper.getDeliveryCharge(
                      context: context,
                      freeDeliveryType: checkoutProvider.getCheckOutData?.freeDeliveryType,
                      orderAmount: widget.amount,
                      distance: checkoutProvider.distance,
                      discount: widget.discount,
                      configModel: configModel,
                      isSelfPickUp: widget.isSelfPickUp
                    );
                    orderProvider.setDeliveryCharge(deliveryCharge);
                    print("------------------------(DELIVERY CHARGE after change)------------- ${orderProvider.deliveryCharge}");

                  },

                  dropdownSearchData: DropdownSearchData(
                    searchController: searchController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      height: 50,
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                      child: TextFormField(
                        controller: searchController,
                        expands: true,
                        maxLines: null,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          hintText: getTranslated('search_zip_area_name', context),
                          hintStyle: const TextStyle(fontSize: Dimensions.fontSizeSmall),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                          ),
                        ),
                      ),
                    ),

                    searchMatchFn: (item, searchValue) {
                      DeliveryChargeByArea areaItem = (splashProvider.deliveryInfoModelList?[checkoutProvider.branchIndex].deliveryChargeByArea ?? [])
                          .firstWhere((element) => element.id.toString() == item.value);
                      return areaItem.areaName?.toLowerCase().contains(searchValue.toLowerCase()) ?? false;
                    },
                  ),
                  buttonStyleData: ButtonStyleData(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    ),
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  ),

                ))),

              ]);
            },
            );
          },
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),


    ]);
  }
}
