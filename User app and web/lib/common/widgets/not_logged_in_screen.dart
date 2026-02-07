import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';

class NotLoggedInScreen extends StatelessWidget {
  const NotLoggedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: Center(
          child: SizedBox(
            height: ResponsiveHelper.isDesktop(context) ? null : MediaQuery.sizeOf(context).height - 150 ,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                    Image.asset(
                      Images.guestLogin,
                      width: MediaQuery.of(context).size.height*0.25,
                      height: MediaQuery.of(context).size.height*0.25,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.03),

                    Text(
                      getTranslated('guest_mode', context),
                      style: rubikBold.copyWith(fontSize: MediaQuery.of(context).size.height*0.023),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),

                    Text(
                      getTranslated('now_you_are_in_guest_mode', context),
                      style: rubikRegular.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.03),

                    SizedBox(
                      height: 40,
                      width: 100,
                      child: CustomButtonWidget(btnTxt: getTranslated('login', context), onTap: () {
                        RouteHelper.getLoginRoute(context, action: RouteAction.push);
                      }),
                    ),

                  ]),
                ),
              ],
            ),
          ),
        )),

        const FooterWebWidget(footerType: FooterType.sliver),

      ],
    );
  }
}
