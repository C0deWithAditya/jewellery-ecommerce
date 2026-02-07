import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageSelectionWidget extends StatelessWidget {
  final Product? productModel;
  const ImageSelectionWidget({Key? key, required this.productModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {

        return Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return SizedBox(
              height: 60,
              child: productProvider.product!.image != null ? ListView.builder(
                itemCount: productProvider.product!.image!.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context,index){
                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () {
                        cartProvider.setSelect(index);
                      },
                      child: Container(
                        width: 60, height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: index == cartProvider.productSelect ? LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ) : null,
                        ),
                        padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 3: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomImageWidget(
                            image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${productProvider.product!.image![index]}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              ) : const SizedBox(),
            );
          }
        );
      }
    );
  }
}
