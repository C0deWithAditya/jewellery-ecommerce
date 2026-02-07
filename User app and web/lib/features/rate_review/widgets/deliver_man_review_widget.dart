import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/common/models/review_body_model.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/rate_review/providers/rate_review_provider.dart';
import 'package:hexacom_user/features/order/widgets/delivery_man_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryManReviewWidget extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  final String orderID;
  const DeliveryManReviewWidget({Key? key, required this.deliveryMan, required this.orderID}) : super(key: key);

  @override
  State<DeliveryManReviewWidget> createState() => _DeliveryManReviewWidgetState();
}

class _DeliveryManReviewWidgetState extends State<DeliveryManReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
            child: Consumer<RateReviewProvider>(
              builder: (context, rateReviewProvider, child) {
                return Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                  widget.deliveryMan != null ? SizedBox(width:Dimensions.webScreenWidth,child: DeliveryManWidget(deliveryMan: widget.deliveryMan)) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Container(
                    width: Dimensions.webScreenWidth,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 5, spreadRadius: 1,
                      )],
                    ),
                    child: Column(children: [
                      Text(
                        getTranslated('rate_his_service', context),
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
                                rateReviewProvider.deliveryManRating < (i + 1) ? Icons.star_border : Icons.star,
                                size: 25,
                                color: rateReviewProvider.deliveryManRating < (i + 1)
                                    ? ColorResources.getGreyColor(context)
                                    : Theme.of(context).primaryColor,
                              ),
                              onTap: () {
                                rateReviewProvider.setDeliveryManRating(i + 1);
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
                        maxLines: 5,
                        capitalization: TextCapitalization.sentences,
                        controller: _controller,
                        hintText: getTranslated('write_your_review_here', context),
                        fillColor: ColorResources.getSearchBg(context),
                      ),
                      const SizedBox(height: 40),

                      // Submit button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Column(
                          children: [
                            !rateReviewProvider.isLoading ? CustomButtonWidget(
                              btnTxt: getTranslated('submit', context),
                              onTap: () {
                                if (rateReviewProvider.deliveryManRating == 0) {
                                  showCustomSnackBar('Give a rating', context);
                                } else if (_controller.text.isEmpty) {
                                  showCustomSnackBar('Write a review', context);
                                } else {
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  ReviewBodyModel reviewBody = ReviewBodyModel(
                                    deliveryManId: widget.deliveryMan!.id.toString(),
                                    rating: rateReviewProvider.deliveryManRating.toString(),
                                    comment: _controller.text,
                                    orderId: widget.orderID,
                                  );
                                  rateReviewProvider.submitDeliveryManReview(reviewBody).then((value) {
                                    if (value.isSuccess) {
                                      showCustomSnackBar(value.message, context, isError: false);
                                      _controller.text = '';
                                    } else {
                                      showCustomSnackBar(value.message, context);
                                    }
                                  });
                                }
                              },
                            ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                          ],
                        ),
                      ),
                    ]),
                  ),

                    ]);
              },
            ),
          ),

          const FooterWebWidget(footerType: FooterType.nonSliver),

        ],
      ),
    );
  }
}
