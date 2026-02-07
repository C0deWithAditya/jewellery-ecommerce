import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/models/review_body_model.dart';
import 'package:hexacom_user/common/reposotories/product_repo.dart';
import 'package:hexacom_user/features/product/domain/models/review_model.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';

class RateReviewProvider extends ChangeNotifier {
  final ProductRepo? productRepo;
  RateReviewProvider({required this.productRepo});


  bool _isLoading = false;
  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  List<ReviewModel>? _productReviewList;
  int _deliveryManRating = 0;
  final double _avgRatting = 0.0;
  final double _totalRatting = 0.0;
  final List<int> _starList = [];

  bool get isLoading => _isLoading;
  List<int> get ratingList => _ratingList;
  List<String> get reviewList => _reviewList;
  List<bool> get loadingList => _loadingList;
  List<bool> get submitList => _submitList;
  int get deliveryManRating => _deliveryManRating;
  List<ReviewModel>? get productReviewList => _productReviewList;
  double get avgRatting => _avgRatting;
  double get totalRatting => _totalRatting;
  List<int> get starList => _starList;

  int fiveStarLength = 0, fourStar = 0, threeStar = 0, twoStar = 0, oneStar = 0;

  set setProductReviewList(List<ReviewModel>? list)=> _productReviewList = list;




  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    for (int i = 0; i < orderDetailsList.length; i++) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    notifyListeners();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    notifyListeners();
  }

  Future<ResponseModel> submitProductReview(int index, ReviewBodyModel reviewBody) async {
    _loadingList[index] = true;
    notifyListeners();

    ApiResponseModel response = await productRepo!.submitReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, getTranslated('review_submit_successfully', Get.context!));
      notifyListeners();
    } else {

      responseModel = ResponseModel(false, ApiCheckerHelper.getError(response).errors?.first.message);
    }
    _loadingList[index] = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel response = await productRepo!.submitDeliveryManReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      _deliveryManRating = 0;
      responseModel = ResponseModel(true, getTranslated('review_submit_successfully', Get.context!));
      notifyListeners();
    } else {

      responseModel = ResponseModel(false, ApiCheckerHelper.getError(response).errors?.first.message);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<void> getProductReviews(int? productID) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel response = await productRepo!.getProductReviewList(productID);
    if (response.response != null && response.response!.statusCode == 200) {
      _productReviewList = [];
      response.response!.data.forEach((review) {
        ReviewModel reviewModel= ReviewModel.fromJson(review);

        _productReviewList!.add(reviewModel);

      });
      fiveStarLength = _productReviewList!.where((element) => element.rating! >= 4.5).length;
      fourStar = _productReviewList!.where((element) => (element.rating! >= 3.5 && element.rating!<4.5)).length;
      threeStar = _productReviewList!.where((element) => (element.rating! >= 2.5 && element.rating!<3.5)).length;
      twoStar = _productReviewList!.where((element) => (element.rating! >= 1.5 && element.rating!<2.5)).length;
      oneStar = _productReviewList!.where((element) => (element.rating! >= 0 && element.rating!<1.5)).length;
    } else {
      ApiCheckerHelper.checkApi(response);
    }
    _isLoading = false;
    notifyListeners();
  }

}
