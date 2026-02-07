import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_zoom_widget.dart';
import 'package:hexacom_user/common/widgets/wish_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductImageWidget extends StatelessWidget {
  final Product? productModel;
  const ProductImageWidget({Key? key, required this.productModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, product, child) {
        return Stack(
          children: [
            SizedBox(
              height: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CustomZoomWidget(
                  child: CustomImageWidget(
                    image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${product.product!.image![Provider.of<CartProvider>(context, listen: false).productSelect]}',
                    fit: ResponsiveHelper.isTab(context) ? BoxFit.fitHeight : BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            ),

            Positioned(
              right: 15, bottom: 15,
              child: WishButtonWidget(product: productModel, countVisible: true),
            ),

          ],
        );
      }
    );
  }
}
