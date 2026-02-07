import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/helper/order_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/order/providers/order_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_single_child_list_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReOrderDialogWidget extends StatelessWidget {
  const ReOrderDialogWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return Dialog(child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
          ),
          width: 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: CustomSingleChildListWidget(
              itemCount: orderProvider.reOrderCartList.length,
              itemBuilder: (index) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ReOrderProductItem(
                    cart: orderProvider.reOrderCartList[index],
                    index: index,
                    orderedProduct: OrderHelper.getOrderedProductProduct(
                      orderProvider.reOrderDetailsModel!,
                      orderProvider.reOrderCartList[index].id,
                    ),
                  ),
                  const Divider(height: Dimensions.paddingSizeDefault),

                ]);
              },
            )),

            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            Row(children: [
              Expanded(child: CustomButtonWidget(
                backgroundColor: Theme.of(context).disabledColor,
                btnTxt: getTranslated('cancel', context),
                onTap: ()=> Navigator.pop(context),
              )),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Expanded(child: CustomButtonWidget(
                btnTxt: getTranslated('confirm', context),
                onTap: (){
                  bool isSuccess =  OrderHelper.addToCartReorderProduct(cartList: orderProvider.reOrderCartList);

                  if(isSuccess){

                    RouteHelper.getDashboardRoute(context, 'cart', action: RouteAction.push);

                  }else{
                    showCustomSnackBar(getTranslated('add_to_cart_is_not_available', context), context);
                  }
                }

              )),
            ])

          ]),
        ));
      }
    );
  }
}

class ReOrderProductItem extends StatelessWidget {
  final Product? orderedProduct;
  final CartModel cart;
  final int index;
  const ReOrderProductItem({Key? key, required this.cart, required this.index, required this.orderedProduct}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String? variationText = '';
    if(cart.variation !=null && cart.variation!.isNotEmpty && cart.variation!.first.type != null) {
      List<String> variationTypes =  cart.variation!.first.type!.split('-');
      if(variationTypes.length == cart.product!.choiceOptions!.length) {
        int index = 0;
        for (var choice in cart.product!.choiceOptions!) {
          variationText = '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      }else {
        variationText = cart.product!.variations![0].type;
      }
    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        bool isProductNotAvailable =  (cartProvider.getCartProductIndex(cart) != null) || (cart.stock ?? 0) < 1 || (cart.variation?.length ?? 0) > 0  && (cart.variation?.first.stock ?? 0)  < 1;

        return Stack(children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: isProductNotAvailable ? Theme.of(context).colorScheme.error.withOpacity(0.3)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomImageWidget(
                    placeholder: Images.placeholder(context),
                    image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${cart.product?.image?[0]}',
                    height: 70, width: 85,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(children: [
                      Expanded(child: Text(
                        cart.product?.name ?? '',
                        style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Row(children: [
                      Expanded(child: CustomDirectionalityWidget(child: Text(
                        PriceConverterHelper.convertPrice(cart.price),
                        style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ))),

                      // Text('${cart.variation} ${cart.unit}', style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                    cart.product!.variations!.isNotEmpty ? Text(
                      variationText!,maxLines: 1,
                      style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      overflow: TextOverflow.ellipsis,
                    ) : const SizedBox(),
                  ],
                )),

              ]),
            ),
          

          Positioned.fill(
            child: Align(alignment: Alignment.topRight, child: Container(
              margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isProductNotAvailable ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
              ),
              child: Icon(
                isProductNotAvailable ? Icons.not_interested_outlined : Icons.done_outlined,
                color: Colors.white, size: Dimensions.paddingSizeLarge,
              ),
            )),
          ),

          if(isProductNotAvailable) Positioned.fill(
            child: Align(alignment: Alignment.bottomRight, child: ReOrderTagView(
              message: getTranslated( cartProvider.getCartProductIndex(cart) != null ? 'already_added' : 'out_of_stock', context),
            )),
          ),
        ]);
      }
    );
  }
}

class ReOrderTagView extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final String message;
  const ReOrderTagView({
    Key? key, this.borderRadius, this.color, required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusSizeDefault),
          bottomRight: Radius.circular(Dimensions.radiusSizeDefault),
        ),
        color: color ?? Theme.of(context).colorScheme.error.withOpacity(0.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: Dimensions.paddingSizeSmall),
      child: Text(message, style: rubikRegular.copyWith(
        fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white,
      )),
    );
  }
}




