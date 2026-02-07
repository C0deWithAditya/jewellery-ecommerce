import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/cart/providers/cart_provider.dart';
import 'package:hexacom_user/features/product/providers/product_provider.dart';
import 'package:hexacom_user/features/product/widgets/details_app_bar_widget.dart';
import 'package:hexacom_user/features/product/widgets/image_selection_widget.dart';
import 'package:hexacom_user/features/product/widgets/product_details_shimmer_widget.dart';
import 'package:hexacom_user/features/product/widgets/product_image_widget.dart';
import 'package:hexacom_user/features/product/widgets/product_title_widget.dart';
import 'package:hexacom_user/features/product/widgets/quantity_widget.dart';
import 'package:hexacom_user/features/product/widgets/related_product_widget.dart';
import 'package:hexacom_user/features/product/widgets/tab_children_widget.dart';
import 'package:hexacom_user/features/product/widgets/tabbar_widget.dart';
import 'package:hexacom_user/features/product/widgets/variation_view_widget.dart';
import 'package:hexacom_user/features/wishlist/providers/wishlist_provider.dart';
import 'package:hexacom_user/helper/cart_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;
  final CartModel? cart;
  const ProductDetailsScreen({Key? key, required this.product, this.cart}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {

  final GlobalKey<DetailsAppBarWidgetState> _key = GlobalKey();



  @override
  void initState() {
    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);
    final WishListProvider wishListProvider = Provider.of<WishListProvider>(context, listen: false);
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);

      productProvider.getProductDetails(widget.product!, widget.cart).then((value){
        wishListProvider.wishProduct = productProvider.product;
      });

      cartProvider.setSelect(0, isUpdate: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<CartProvider>(builder: (context, cartProvider, _)=> Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        double? priceWithQuantity;
        double? priceWithDiscount;
        bool isExistInCart = false;
        CartModel? cartModel;


        if(productProvider.product != null){

          cartModel = CartHelper.getCartModel(productProvider.product!, variationIndexList: productProvider.variationIndex, quantity: productProvider.quantity);
          priceWithDiscount = PriceConverterHelper.convertWithDiscount((cartModel?.price ?? 0), productProvider.product!.discount, productProvider.product!.discountType);

          isExistInCart = cartProvider.isExistInCart(cartModel, false, null);

          if(isExistInCart) {
            priceWithQuantity = priceWithDiscount! * cartProvider.cartList[cartProvider.getCartProductIndex(cartModel)!]!.quantity!;

          }else {
            priceWithQuantity = priceWithDiscount! * productProvider.quantity!;

          }
        }

        return Scaffold(
          backgroundColor: Theme.of(context).cardColor,

          appBar: ResponsiveHelper.isDesktop(context) ? const CustomAppBarWidget() : DetailsAppBarWidget(key: _key),

          body: productProvider.product != null ? Column(children: [
            Expanded(child: CustomScrollView(
              slivers: [

                if(!ResponsiveHelper.isDesktop(context))  SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        ProductImageWidget(productModel: productProvider.product),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        ImageSelectionWidget(productModel: productProvider.product),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        ProductTitleWidget(productModel: productProvider.product),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        /// Quantity
                        Row(children: [
                          Text(getTranslated('quantity', context), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor)),
                          const Expanded(child: SizedBox()),

                          QuantityWidget(cartModel: cartModel, isExistInCart: isExistInCart, stock: cartModel?.stock ?? 0),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        /// Price
                        Row(children: [

                          if( (productProvider.product?.price ?? 0) > priceWithDiscount!) Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              PriceConverterHelper.convertPrice(productProvider.product?.price),
                              style: rubikRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeDefault, decoration: TextDecoration.lineThrough),
                            ),
                          ),
                          if( (productProvider.product?.price ?? 0) > priceWithDiscount) const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),

                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              PriceConverterHelper.convertPrice(priceWithDiscount),
                              style: rubikBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraLarge),
                            ),
                          ),

                        ]),
                        const SizedBox(height: Dimensions.paddingSizeDefault),


                        /// Variation
                        const VariationViewWidget(),


                        productProvider.product!.choiceOptions!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),


                        TabBarWidget(productId: widget.product?.id, child: const TabChildrenWidget()),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        RelatedProductWidget(productDetailsModel: productProvider.productDetailsModel),


                      ]),
                ),),

                if(ResponsiveHelper.isDesktop(context))  SliverToBoxAdapter(child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Center(child: SizedBox(
                    width: Dimensions.webScreenWidth,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start,  children: [

                      Expanded(flex: 4, child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                        ProductImageWidget(productModel: productProvider.product),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        ImageSelectionWidget(productModel: productProvider.product),

                      ])),

                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            ///Product Title
                            ProductTitleWidget(productModel: productProvider.product),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            /// Price
                            Row(children: [

                              if( (productProvider.product?.price ?? 0) > priceWithDiscount!) Text(
                                PriceConverterHelper.convertPrice(productProvider.product?.price),
                                style: rubikRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeDefault, decoration: TextDecoration.lineThrough),
                              ),
                              if( (productProvider.product?.price ?? 0) > priceWithDiscount) const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),

                              Text(
                                PriceConverterHelper.convertPrice(priceWithDiscount),
                                style: rubikBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraLarge),
                              ),

                            ]),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            /// Variation
                            const VariationViewWidget(),
                            productProvider.product!.choiceOptions!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            /// Total Amount
                            Row(children: [

                              Text('${getTranslated('total_amount', context)}:', style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              CustomDirectionalityWidget(
                                child: Text(PriceConverterHelper.convertPrice(priceWithQuantity), style: rubikBold.copyWith(
                                  color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge,
                                )),
                              ),

                            ]),
                            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                            Row( children: [

                              QuantityWidget(cartModel: cartModel, isExistInCart: isExistInCart, stock: cartModel?.stock ?? 0),
                              const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                              SizedBox(
                                height: 40, width: 300,
                                child: CustomButtonWidget(
                                  btnTxt: getTranslated(isExistInCart ? 'already_added_in_cart' : (cartModel?.stock ?? 0) <= 0 ? 'out_of_stock' : 'add_to_cart', context),
                                  backgroundColor: Theme.of(context).primaryColor,
                                  radius: Dimensions.radiusSizeFifty,
                                  iconData: (cartModel?.stock ?? 0) <= 0 ? null : Icons.shopping_cart,
                                  onTap: (!isExistInCart && (cartModel?.stock ?? 0) > 0) ?  () {
                                    if(!isExistInCart && (cartModel?.stock ?? 0) > 0) {
                                      Provider.of<CartProvider>(context, listen: false).addToCart(cartModel!, null);
                                      showCustomSnackBar(getTranslated('added_to_cart', context), context, isError: false);
                                    }
                                  } : null,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeLarge),

                            ]),
                          ]),
                        ),
                      ),
                    ]),
                  )),
                  const SizedBox(height: 20),

                  TabBarWidget(productId: widget.product?.id, child: const TabChildrenWidget()),

                  Center(child: SizedBox(
                    width: Dimensions.webScreenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        RelatedProductWidget(productDetailsModel: productProvider.productDetailsModel),

                      ],
                    ),
                  )),


                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                ])),

                const FooterWebWidget(footerType: FooterType.sliver),
              ],
            )),


            if(!ResponsiveHelper.isDesktop(context)) SafeArea(
              child: Container(
                width: Dimensions.webScreenWidth,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButtonWidget(
                  btnTxt: getTranslated(isExistInCart ? 'already_added_in_cart' : (cartModel?.stock ?? 0) <= 0 ? 'out_of_stock' : 'add_to_cart', context),
                  radius: Dimensions.radiusSizeFifty,
                  backgroundColor: Theme.of(context).primaryColor,
                  onTap: (!isExistInCart && (cartModel?.stock ?? 0) > 0) ?  () {
                    if(!isExistInCart && (cartModel?.stock ?? 0) > 0) {
                      Provider.of<CartProvider>(context, listen: false).addToCart(cartModel!, null);
                      _key.currentState!.shake();
                      showCustomSnackBar(getTranslated('added_to_cart', context), context, isError: false);
                    }
                  } : null,
                ),
              ),
            ),

          ]) :  ProductDetailsShimmerWidget(isEnabled: true,isWeb: ResponsiveHelper.isDesktop(context)? true : false),
        );
      },
    ));
  }
}






