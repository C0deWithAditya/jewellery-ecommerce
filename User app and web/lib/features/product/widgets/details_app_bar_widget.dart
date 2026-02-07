import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailsAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  @override
  const DetailsAppBarWidget({Key? key}) : super(key: key);

  @override
  DetailsAppBarWidgetState createState() => DetailsAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}

class DetailsAppBarWidgetState extends State<DetailsAppBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);

    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 15.0).chain(CurveTween(curve: Curves.elasticIn)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return AppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color), onPressed: () => Navigator.pop(context)),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      title: Text(
        getTranslated('product_details', context),
        style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
      ),
      centerTitle: true,
      actions: [AnimatedBuilder(
        animation: offsetAnimation,
        builder: (buildContext, child) {
          return Container(
            padding: EdgeInsets.only(left: offsetAnimation.value + 15.0, right: 15.0 - offsetAnimation.value),
            child: Stack(children: [
              IconButton(icon: Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor), onPressed: () {

                RouteHelper.getDashboardRoute(context, 'cart', action: RouteAction.push);

              }),
              Positioned(
                top: 5, right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  child: Text(
                    '${CartHelper.getCartItemCount(cartProvider.cartList)}',
                    style: rubikMedium.copyWith(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),

            ]),
          );
        },
      )],
    );
  }
}
