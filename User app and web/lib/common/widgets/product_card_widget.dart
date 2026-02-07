import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final Axis direction;
  const ProductCardWidget({super.key, required this.product, this.direction = Axis.vertical});

  @override
  Widget build(BuildContext context) {

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {

        PriceRange priceRange = PriceConverterHelper.getPriceRange(product);
        double? discountedPrice = PriceConverterHelper.convertWithDiscount(product.price, product.discount, product.discountType);

        CartModel? cartModel = CartHelper.getCartModel(product);
        int? cartIndex = cartProvider.getCartProductIndex(cartModel);
        bool isExistInCart =  cartIndex != null;

        return OnHover(isItem: true, child: InkWell(
          hoverColor: Colors.transparent,
          onTap: ()=> RouteHelper.getProductDetailsRoute(context, product.id),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05), width: 1),
              boxShadow: [BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.05),
                blurRadius: 30, offset: const Offset(2, 10),
              )],
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: direction == Axis.vertical ? Column(mainAxisSize: MainAxisSize.min, children: [

              ProductImageView(
                product: product,
                isExistInCart: isExistInCart,
                cartModel: cartModel,
                cartIndex: cartIndex,
                direction: direction,
              ),

              _ProductDescriptionView(
                product: product,
                discountedPrice: discountedPrice,
                priceRange: priceRange,
                direction: direction,
              ),

            ]) : Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
              ProductImageView(
                product: product,
                isExistInCart: isExistInCart,
                cartModel: cartModel,
                cartIndex: cartIndex,
                direction: direction,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Flexible(
                child: _ProductDescriptionView(
                  product: product,
                  discountedPrice: discountedPrice,
                  priceRange: priceRange,
                  direction: direction,
                ),
              ),
            ]),
          ),
        ));
      }
    );
  }
}

class _ProductDescriptionView extends StatelessWidget {
  const _ProductDescriptionView({
    required this.product,
    required this.discountedPrice,
    required this.priceRange,
    required this.direction,
  });

  final Product product;
  final double? discountedPrice;
  final PriceRange priceRange;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final isVertical = direction == Axis.vertical;

    return Column(crossAxisAlignment: isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [
      const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(mainAxisAlignment: isVertical ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween, children: [
          product.rating != null && product.rating!.isNotEmpty && (product.rating!.first.average?.length ?? 0) > 0  ?
            _ProductRatingView(isVertical: isVertical, product: product) : const SizedBox(),

          if(!isVertical) ProductWishListButton(product: product)
        ]),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),



      Text(
        product.name ?? '', maxLines: 2, textAlign: direction == Axis.vertical ? TextAlign.center : TextAlign.start,
        overflow: TextOverflow.ellipsis, style: rubikRegular,
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      _PriceView(product: product, discountedPrice: discountedPrice, price: priceRange.startPrice ?? 0, direction: direction),



    ]);
  }
}

class _ProductRatingView extends StatelessWidget {
  const _ProductRatingView({
    required this.isVertical,
    required this.product,
  });

  final bool isVertical;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: isVertical ? MainAxisAlignment.center : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
         Icon(Icons.star_rounded, color: ColorResources.getRatingColor(context), size: 20),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Text(double.parse(product.rating?.first.average ?? '0').toStringAsFixed(1), style: rubikMedium),
      ]);
  }
}

class ProductWishListButton extends StatelessWidget {
  final Product product;
  const ProductWishListButton({
    super.key, required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WishListProvider>(
      builder: (context, wishListProvider, _) {
        return InkWell(
          onTap: (){
            if(Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
              List<int?> productIdList = [];
              productIdList.add(product.id);

              if(wishListProvider.wishIdList.contains(product.id)){

                ResponsiveHelper.showDialogOrBottomSheet(context, CustomAlertDialogWidget(
                  title: getTranslated('remove_from_wish_list', context),
                  subTitle: getTranslated('remove_this_item_from_your_favorite_list', context),
                  icon: Icons.contact_support_outlined,
                  leftButtonText: getTranslated('cancel', context),
                  rightButtonText: getTranslated('remove', context),
                  buttonColor: Theme.of(context).colorScheme.error.withOpacity(0.9),
                  onPressRight: (){
                    Navigator.pop(context);
                    wishListProvider.removeFromWishList(product, context);


                  },

                ));

              }else{
                wishListProvider.addToWishList(product);
              }

            }else{
              showCustomSnackBar(getTranslated('now_you_are_in_guest_mode', context), context);
            }
          },
          child: Container(
            height: 35, width: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.9),
              border: Border.all(width: 0.6, color: Theme.of(context).hintColor.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            ),
            alignment: Alignment.center,
            child: Icon(wishListProvider.wishIdList.contains(product.id) ? Icons.favorite : Icons.favorite_border,
                color: wishListProvider.wishIdList.contains(product.id) ? Theme.of(context).primaryColor :
                Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault ),
          ),
        );
      }
    );
  }
}

class ProductImageView extends StatelessWidget {
  const ProductImageView({super.key,
    required this.product,
    required this.isExistInCart,
    required this.cartModel,
    required this.cartIndex,
    required this.direction,
  });

  final Product product;
  final bool isExistInCart;
  final CartModel? cartModel;
  final int? cartIndex;
  final Axis? direction;

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final isVertical = direction == Axis.vertical;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05), width: 1),
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                  boxShadow: [BoxShadow(
                    color: Theme.of(context).focusColor.withOpacity(0.05),
                    blurRadius: 30, offset: const Offset(15, 15),
                  )]
              ),
              child: Stack(children: [
                CustomImageWidget(
                  image: '${splashProvider.baseUrls!.productImageUrl}/${product.image![0]}',
                  width: isVertical ? 350 : 150,
                  fit: BoxFit.cover,
                  height: 160,
                ),

                if(isVertical) Positioned.fill(child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: ProductWishListButton(product: product),
                  ),
                )),

                Positioned.fill(child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(top: isVertical ? 55 : 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: (){
                        if(product.variations == null || product.variations!.isEmpty) {
                          if (isExistInCart) {
                            showCustomSnackBar(getTranslated('already_added', context), context);
                          } else if ((cartModel?.stock ?? 0)  < 1) {
                            showCustomSnackBar(getTranslated('out_of_stock', context), context);
                          } else {
                            cartProvider.addToCart(cartModel!, null);
                            showCustomSnackBar(getTranslated('added_to_cart', context), context, isError: false);
                          }
                        }else {
                          RouteHelper.getProductDetailsRoute(context, product.id);
                        }
                      },
                      child: Container(
                        height: isExistInCart ? 80 : 35, width: 35,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.9),
                          border: Border.all(width: 0.6, color: Theme.of(context).hintColor.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                        ),
                        alignment: Alignment.center,
                        child: isExistInCart ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          InkWell(
                            onTap: () => cartProvider.setQuantity(
                              true, cartModel, cartModel?.stock, context,
                              true, cartProvider.getCartProductIndex(cartModel),
                            ),
                            child: const Icon(Icons.add),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Text('${cartProvider.cartList[cartIndex!]?.quantity}', style: rubikBold.copyWith(color: Theme.of(context).textTheme.titleLarge?.color)),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          InkWell(
                            onTap: (){


                              if (cartProvider.cartList[cartIndex!]!.quantity! > 1) {
                                cartProvider.setQuantity(
                                  false, cartModel, cartModel!.stock,
                                  context,true, cartProvider.getCartProductIndex(cartModel),
                                );

                              }else if(cartProvider.cartList[cartIndex!]?.quantity == 1) {
                                cartProvider.removeFromCart(cartProvider.cartList[cartIndex!]!);
                              }
                            },

                            child: const Icon(Icons.remove_outlined),
                          ),

                        ]) : Icon(
                          Icons.shopping_cart, size: Dimensions.paddingSizeDefault,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                )),

                product.discount != 0 ? Positioned(
                  left: 10, top: 10,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorResources.getRatingColor(context),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: CustomDirectionalityWidget(
                            child: Text(
                              product.discountType == 'percent' ? '-${product.discount} %' : '-${PriceConverterHelper.convertPrice(product.discount)}',
                              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ) : const SizedBox(),

              ]),
            ),
          ),
        );
      }
    );
  }
}

class _PriceView extends StatelessWidget {
  const _PriceView({
    required this.product,
    required this.discountedPrice,
    required this.price, this.direction = Axis.vertical,
  });

  final Product product;
  final double? discountedPrice;
  final double price;
  final Axis? direction;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: direction == Axis.vertical ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
      product.price! > discountedPrice! ? CustomDirectionalityWidget(
        child: Text(PriceConverterHelper.convertPrice(price), style: rubikRegular.copyWith(
          color: Theme.of(context).hintColor,
          decoration: TextDecoration.lineThrough,
          fontSize: Dimensions.fontSizeExtraSmall,
        )),
      ) : const SizedBox(),

      Flexible(
        child: FittedBox(child: CustomDirectionalityWidget(
          child: Text(
            PriceConverterHelper.convertPrice(price, discount: product.discount, discountType: product.discountType),
            style: rubikMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )),
      ),

    ]);
  }
}
