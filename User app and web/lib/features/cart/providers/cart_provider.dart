import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/features/cart/domain/reposotories/cart_repo.dart';

class CartProvider extends ChangeNotifier {
  final CartRepo? cartRepo;
  CartProvider({required this.cartRepo});

  List<CartModel?> _cartList = [];
  double _amount = 0.0;

  List<CartModel?> get cartList => _cartList;
  double get amount => _amount;

  int _productSelect = 0;
  int get productSelect => _productSelect;

  void setSelect(int select, {bool isUpdate = true}){
    _productSelect = select;

    if(isUpdate) {
      notifyListeners();
    }
  }

  void getCartData({bool isUpdate = false}) {
    _cartList = [];
    _cartList.addAll(cartRepo!.getCartList());
    for (var cart in _cartList) {
      _amount = _amount + (cart!.discountedPrice! * cart.quantity!);
    }
    if(isUpdate) {
      notifyListeners();
    }
  }

  void addToCart(CartModel cartModel, int? index) {
    if(index != null) {
      _amount = _amount - (_cartList[index]!.discountedPrice! * _cartList[index]!.quantity!);
      _cartList.replaceRange(index, index+1, [cartModel]);
    }else {
      _cartList.add(cartModel);
    }
    _amount = _amount + (cartModel.discountedPrice! * cartModel.quantity!);
    cartRepo!.addToCartList(_cartList);
    notifyListeners();
  }

  void setQuantity(bool isIncrement, CartModel? cart, int? stock, BuildContext context, bool fromProductDetails, int? productIndex) {
    int? index = fromProductDetails ? productIndex :  _cartList.indexOf(cart);
    if (isIncrement) {
      if(_cartList[index!]!.quantity! >= stock!) {
        showCustomSnackBar(getTranslated('out_of_stock', context), context);
      }else {
        _cartList[index]!.quantity = _cartList[index]!.quantity! + 1;
        _amount = _amount + _cartList[index]!.discountedPrice!;
      }
    } else {
      _cartList[index!]!.quantity = _cartList[index]!.quantity! - 1;
      _amount = _amount - _cartList[index]!.discountedPrice!;
    }
    cartRepo!.addToCartList(_cartList);

    notifyListeners();
  }

  void removeFromCart(CartModel cart) {
    _cartList.remove(cart);
    _amount = _amount - (cart.discountedPrice! * cart.quantity!);
    cartRepo!.addToCartList(_cartList);


    notifyListeners();
  }

  void clearCartList() {
    _cartList = [];
    _amount = 0;
    cartRepo!.addToCartList(_cartList);
    notifyListeners();
  }

  bool isExistInCart(CartModel? cartModel, bool isUpdate, int? cartIndex) {
    for(int index=0; index<_cartList.length; index++) {
      if(_cartList[index]!.product!.id == cartModel!.product!.id && (_cartList[index]!.variation!.isNotEmpty ? _cartList[index]!.variation![0].type == cartModel.variation![0].type : true)) {
        if((isUpdate && index == cartIndex)) {
          return false;
        }else {
          return true;
        }
      }
    }
    return false;
  }
  int? getCartProductIndex(CartModel? cartModel) {
    for(int index = 0; index < _cartList.length; index ++) {
      if(_cartList[index]?.product?.id == cartModel?.product?.id && (
          (_cartList[index]?.variation?.isNotEmpty ?? false) && (cartModel?.variation?.isNotEmpty ?? false) ? _cartList[index]!.variation![0].type == cartModel!.variation![0].type : true
      )) {
        return index;
      }
    }
    return null;
  }

}
