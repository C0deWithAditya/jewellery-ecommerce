import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/features/coupon/widgets/coupon_custom_painter_widget.dart';
import 'package:hexacom_user/helper/date_converter_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/coupon/providers/coupon_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(isLoggedIn) {
      Provider.of<CouponProvider>(context, listen: false).getCouponList(context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor.withOpacity(0.2),
      appBar: CustomAppBarWidget(title: getTranslated('coupon', context)),
      body: isLoggedIn ? Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          return couponProvider.couponList != null ? couponProvider.couponList!.isNotEmpty ? RefreshIndicator(
            color: Theme.of(context).secondaryHeaderColor,
            onRefresh: () async {
              await couponProvider.getCouponList(context);
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: StaggeredGrid.count(
                        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : 1,
                        children: couponProvider.couponList!.map((couponModel) => CustomPaint(
                          size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                          painter: CouponCustomPainterWidget(),
                          child: InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: couponModel.code ?? ''));
                              showCustomSnackBar(getTranslated('coupon_code_copied', context), context, isError: false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 70),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [

                                          Container(
                                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.fontSizeDefault),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                                            ),
                                            child: Row(children: [
                                              Text(
                                                '${couponModel.discount}${couponModel.discountType == 'percent' ? '%'
                                                    : Provider.of<SplashProvider>(context, listen: false).configModel!.currencySymbol}',
                                                style: rubikBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge),
                                              ),
                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                              Text(getTranslated('off', context).toUpperCase(), style: rubikRegular.copyWith(
                                                fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white,
                                              )),

                                            ]),
                                          ),


                                        ],
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                      Text(
                                        '${getTranslated('valid_until', context)} ${DateConverterHelper.isoStringToLocalDateOnly(couponModel.expireDate!)}',
                                        style: rubikMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    alignment: Alignment.center,
                                    transform: Matrix4.translationValues(0.0, 8.1, 0.0),
                                    child: Stack(children: [
                                      Image.asset( couponModel.discountType == 'percent' ? Images.percent : Images.amount, width: 100),

                                      Text(couponModel.code ?? '', style: rubikMedium.copyWith(color: Theme.of(context).primaryColor)),
                                    ]),
                                  ),


                                ],
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ),

                const FooterWebWidget(footerType: FooterType.sliver),

              ],
            ),
          ) : const NoDataScreen(showFooter: true) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
        },
      ) : const NotLoggedInScreen(),
    );
  }
}


