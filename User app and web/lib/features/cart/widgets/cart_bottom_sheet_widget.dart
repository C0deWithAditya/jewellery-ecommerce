import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/rating_bar_widget.dart';
import 'package:hexacom_user/common/widgets/wish_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartBottomSheetWidget extends StatelessWidget {
  final Product? product;
  final bool fromOfferProduct;
  final Function? callback;
  final CartModel? cart;
  final int? cartIndex;
  const CartBottomSheetWidget({super.key, required this.product, this.fromOfferProduct = false, this.callback, this.cart, this.cartIndex});

  @override
  Widget build(BuildContext context) {
    Provider.of<ProductProvider>(context, listen: false).initDataLoad(product, cart, isUpdate: false);
    Provider.of<RateReviewProvider>(context, listen: false).setProductReviewList = [];

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          ),
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              PriceRange priceRange = PriceConverterHelper.getPriceRange(product!);

              CartModel? cartModel = CartHelper.getCartModel(product!, variationIndexList: productProvider.variationIndex);

              double? discountedPrice = PriceConverterHelper.convertWithDiscount((cartModel?.price ?? 0), product?.discount, product?.discountType);

              int? cartIndex = cartProvider.getCartProductIndex(cartModel);
              bool isExistInCart =  cartIndex != null;

              double priceWithQuantity = (discountedPrice ?? 0) * (isExistInCart ? (cartProvider.cartList[cartIndex]?.quantity ?? 1) : productProvider.quantity ?? 1);


              return SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  //Product
                  Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FadeInImage.assetNetwork(
                        placeholder: Images.placeholder(context),
                        image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${product!.image![0]}',
                        width: 100, height: 100, fit: BoxFit.cover,
                        imageErrorBuilder: (a, b, c) => Image.asset(Images.placeholder(context), width: 100, height: 100, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          product?.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                        if(product!.rating != null) RatingBarWidget(rating: product!.rating!.isNotEmpty ? double.parse(product!.rating![0].average!) : 0.0, size: 15),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomDirectionalityWidget(
                              child: Text(
                                '${PriceConverterHelper.convertPrice(priceRange.startPrice, discount: product!.discount, discountType: product!.discountType)}'
                                    '${priceRange.endPrice != null ? ' - ${PriceConverterHelper.convertPrice(priceRange.endPrice, discount: product!.discount,
                                    discountType: product!.discountType)}' : ''}',
                                style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                              ),
                            ),

                            product?.price == discountedPrice ? WishButtonWidget(product: product) : const SizedBox(),
                          ],
                        ),
                        (product?.price ?? 0) > (discountedPrice ?? 0) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          CustomDirectionalityWidget(
                            child: Text(
                              '${PriceConverterHelper.convertPrice(priceRange.startPrice)}'
                                  '${priceRange.endPrice!= null ? ' - ${PriceConverterHelper.convertPrice(priceRange.endPrice)}' : ''}',
                              style: rubikMedium.copyWith(color: ColorResources.colorGrey, decoration: TextDecoration.lineThrough),
                            ),
                          ),
                          WishButtonWidget(product: product),
                        ]) : const SizedBox(),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Quantity
                  Row(children: [
                    Text(getTranslated('quantity', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const Expanded(child: SizedBox()),
                    Container(
                      decoration: BoxDecoration(color: ColorResources.getBackgroundColor(context), borderRadius: BorderRadius.circular(5)),
                      child: Row(children: [
                        InkWell(
                          onTap: () {
                            if(isExistInCart && cart!.quantity! > 1) {
                              cartProvider.setQuantity(false, cart, cart?.stock, context, true, cartProvider.getCartProductIndex(cart));
                            }else {
                              if (productProvider.quantity! > 1) {
                                productProvider.setProductQuantity(false, cartModel?.stock, context);
                              }
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                            child: Icon(Icons.remove, size: 20),
                          ),
                        ),
                        Text(
                          isExistInCart ? cartProvider.cartList[cartIndex]!.quantity.toString() : productProvider.quantity.toString(),
                          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                        ),

                        InkWell(
                          onTap: () => isExistInCart
                              ? cartProvider.setQuantity(true, cart, cart!.stock, context, true, cartIndex )
                              :  productProvider.setProductQuantity(true, cartModel?.stock, context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                            child: Icon(Icons.add, size: 20),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Variation
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: product!.choiceOptions!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(product!.choiceOptions![index].title!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 10,
                            childAspectRatio: (1 / 0.25),
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: product!.choiceOptions![index].options!.length,
                          itemBuilder: (context, i) {
                            return InkWell(
                              onTap: () {
                                productProvider.setCartVariationIndex(index, i);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  color: productProvider.variationIndex![index] != i ? Theme.of(context).dividerColor.withOpacity(0.3) : Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                  border: productProvider.variationIndex![index] != i ? Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 1) : null,
                                ),
                                child: Text(
                                  product!.choiceOptions![index].options![i].trim(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: rubikRegular.copyWith(
                                    color: productProvider.variationIndex![index] != i ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: index != product!.choiceOptions!.length-1 ? Dimensions.paddingSizeLarge : 0),
                      ]);
                    },
                  ),
                  product!.choiceOptions!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                  fromOfferProduct ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(getTranslated('description', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(product!.description ?? '', style: rubikRegular),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ]) : const SizedBox(),

                  Row(children: [
                    Text('${getTranslated('total_amount', context)}:', style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    CustomDirectionalityWidget(
                      child: Text(PriceConverterHelper.convertPrice(priceWithQuantity), style: rubikBold.copyWith(
                        color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge,
                      )),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomButtonWidget(
                    btnTxt: getTranslated((cartModel?.stock ?? 0) <= 0 ? 'out_of_stock' : cartIndex != null ? 'already_added_in_cart' : 'add_to_cart', context),
                    backgroundColor: Theme.of(context).primaryColor,
                    onTap: cartIndex != null ? null : ((cartModel?.stock ?? 0) > 0) ?  () {
                      if(!isExistInCart && (cartModel?.stock ?? 0) > 0) {
                        Navigator.pop(context);
                        cartProvider.addToCart(cartModel!, cartIndex);
                        callback!(cartModel);
                      }else{
                        Navigator.pop(context);

                      }
                    } : null,
                  ),

                ]),
              );
            },
          ),
        );
      }
    );
  }
}


