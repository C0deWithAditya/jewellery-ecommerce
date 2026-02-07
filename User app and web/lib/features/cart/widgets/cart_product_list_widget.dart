import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/cart/widgets/cart_product_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartProductListWidget extends StatelessWidget {
  const CartProductListWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, _)=> ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: cartProvider.cartList.length,
      itemBuilder: (context, index)=> CartProductWidget(
        cart: cartProvider.cartList[index],
        cartIndex: index,
      ),
    ),
    );
  }
}
