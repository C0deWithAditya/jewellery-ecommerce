import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/review_body_model.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:provider/provider.dart';

class ProductReviewWidget extends StatelessWidget {
  final List<OrderDetailsModel>? orderDetailsList;
  const ProductReviewWidget({Key? key, required this.orderDetailsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
              child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: Consumer<RateReviewProvider>(
                  builder: (context, rateReviewProvider, child) {
                    return ListView.builder(
                      itemCount: orderDetailsList!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))],
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                          ),
                          child: Column(
                            children: [

                              // Product details
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: Images.placeholder(context),
                                      image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${orderDetailsList![index].productDetails!.image![0]}',
                                      height: 70,
                                      width: 85,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), width: 70, height: 85),

                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(orderDetailsList![index].productDetails!.name!, style: rubikMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 10),

                                      Text(PriceConverterHelper.convertPrice(orderDetailsList![index].productDetails!.price), style: rubikBold),
                                    ],
                                  )),
                                ],
                              ),
                              const Divider(height: 20),

                              // Rate
                              Text(
                                getTranslated('rate_the_food', context),
                                style: rubikMedium.copyWith(color: ColorResources.getGreyBunkerColor(context)), overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              SizedBox(
                                height: 30,
                                child: ListView.builder(
                                  itemCount: 5,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, i) {
                                    return InkWell(
                                      child: Icon(
                                        rateReviewProvider.ratingList[index] < (i + 1) ? Icons.star_border : Icons.star,
                                        size: 25,
                                        color: rateReviewProvider.ratingList[index] < (i + 1)
                                            ? ColorResources.getGreyColor(context)
                                            : Theme.of(context).primaryColor,
                                      ),
                                      onTap: () {
                                        if(!rateReviewProvider.submitList[index]) {
                                          rateReviewProvider.setRating(index, i + 1);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              Text(
                                getTranslated('share_your_opinion', context),
                                style: rubikMedium.copyWith(color: ColorResources.getGreyBunkerColor(context)), overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              CustomTextFieldWidget(
                                maxLines: 3,
                                capitalization: TextCapitalization.sentences,
                                isEnabled: !rateReviewProvider.submitList[index],
                                hintText: getTranslated('write_your_review_here', context),
                                fillColor: ColorResources.getSearchBg(context),
                                onChanged: (text) {
                                  rateReviewProvider.setReview(index, text);
                                },
                              ),
                              const SizedBox(height: 20),

                              // Submit button
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                child: Column(
                                  children: [
                                    !rateReviewProvider.loadingList[index] ? CustomButtonWidget(
                                      btnTxt: getTranslated(rateReviewProvider.submitList[index] ? 'submitted' : 'submit', context),
                                      backgroundColor: rateReviewProvider.submitList[index] ? ColorResources.getGreyColor(context) : Theme.of(context).primaryColor,
                                      onTap: () {
                                        if(!rateReviewProvider.submitList[index]) {
                                          if (rateReviewProvider.ratingList[index] == 0) {
                                            showCustomSnackBar('Give a rating', context);
                                          } else if (rateReviewProvider.reviewList[index].isEmpty) {
                                            showCustomSnackBar('Write a review', context);
                                          } else {
                                            FocusScopeNode currentFocus = FocusScope.of(context);
                                            if (!currentFocus.hasPrimaryFocus) {
                                              currentFocus.unfocus();
                                            }
                                            ReviewBodyModel reviewBody = ReviewBodyModel(
                                              productId: orderDetailsList![index].productId.toString(),
                                              rating: rateReviewProvider.ratingList[index].toString(),
                                              comment: rateReviewProvider.reviewList[index],
                                              orderId: orderDetailsList![index].orderId.toString(),
                                            );
                                            rateReviewProvider.submitProductReview(index, reviewBody).then((value) {
                                              if (value.isSuccess) {
                                                showCustomSnackBar(value.message, context, isError: false);
                                                rateReviewProvider.setReview(index, '');
                                              } else {
                                                showCustomSnackBar(value.message, context);
                                              }
                                            });
                                          }
                                        }
                                      },
                                    ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          const FooterWebWidget(footerType: FooterType.nonSliver),

        ],
      ),
    );
  }
}
