import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class QuantityWidget extends StatelessWidget {
  final CartModel? cartModel;
  final bool isExistInCart;
  final int stock;
  const QuantityWidget({Key? key, required this.cartModel, required this.isExistInCart, required this.stock}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          return Container(
            decoration: BoxDecoration(
              color: ColorResources.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? 40 : 25),
            ),
            child: Row(children: [
              _QuantityButtonWidget(
                isIncrement: false,
                quantity: isExistInCart
                    ? cartProvider.cartList[cartProvider.getCartProductIndex(cartModel)!]!.quantity
                    : productProvider.quantity,
                stock: stock,
                isExistInCart : isExistInCart,
                cart: cartModel,
              ),
              if(ResponsiveHelper.isDesktop(context)) const SizedBox(width: 30),

              Text(
                isExistInCart ? cartProvider.cartList[cartProvider.getCartProductIndex(cartModel)!]!.quantity.toString() : productProvider.quantity.toString(),
                style: rubikBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
              ),
              if(ResponsiveHelper.isDesktop(context)) const SizedBox(width: 30),


              _QuantityButtonWidget(
                isIncrement: true, quantity: isExistInCart
                  ? cartProvider.cartList[cartProvider.getCartProductIndex(cartModel)!]!.quantity
                  : productProvider.quantity,
                stock: stock, cart: cartModel,
                isExistInCart: isExistInCart,
              ),
            ]),
          );
        }
    );
  }

}


class _QuantityButtonWidget extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final int? stock;
  final bool isExistInCart;
  final CartModel? cart;
  const _QuantityButtonWidget({Key? key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: ResponsiveHelper.isDesktop(context) ? 40 : 25,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap:  () {
        if(isExistInCart) {
          if (!isIncrement && quantity! > 1) {
            Provider.of<CartProvider>(context, listen: false).setQuantity(false, cart, cart!.stock, context,true, Provider.of<CartProvider>(context, listen: false).getCartProductIndex(cart));
          } else if (isIncrement) {
            if(quantity! < stock!) {
              Provider.of<CartProvider>(context, listen: false).setQuantity(true, cart, cart!.stock, context,true, Provider.of<CartProvider>(context, listen: false).getCartProductIndex(cart));
            }else {
              showCustomSnackBar(getTranslated('out_of_stock', context), context);
            }
          }
        } else {
          if (!isIncrement && quantity! > 1) {
            Provider.of<ProductProvider>(context, listen: false).setProductQuantity(false, stock, context);
          } else if (isIncrement) {
            if(quantity! < stock!) {
              Provider.of<ProductProvider>(context, listen: false).setProductQuantity(true, stock, context);
            }else {
              showCustomSnackBar(getTranslated('out_of_stock', context), context);
            }
          }

        }
      },
      child: SizedBox(
        height: 40,width: 40,
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement
                ? Theme.of(context).primaryColor
                : quantity! > 1
                ? Theme.of(context).disabledColor
                : Theme.of(context).disabledColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}