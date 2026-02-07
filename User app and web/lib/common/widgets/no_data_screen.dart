import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';

class NoDataScreen extends StatelessWidget {
  final bool showFooter;
  final bool scrollable;
  final String? image;
  final String? title;
  final String? subTitle;
  const NoDataScreen({
    super.key,
   this.showFooter = false, this.scrollable = false, this.image, this.title, this.subTitle,

  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: scrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 0.0 : size.height),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                if(ResponsiveHelper.isDesktop(context)) SizedBox(height: size.height * 0.11),

                Image.asset(
                  image ?? Images.noDataImage,
                  width: size.height * 0.22,
                  height:size.height * 0.22,
                  color: Theme.of(context).disabledColor.withOpacity(0.1),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(
                  title ?? getTranslated('nothing_found', context),
                  style: rubikSemiBold.copyWith(color: Theme.of(context).disabledColor.withOpacity(0.1), fontSize: size.height * 0.023),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

               if(subTitle != null) Text(
                 subTitle ?? '',
                  style: rubikMedium.copyWith(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                    fontSize: size.height * 0.0175,
                  ), textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.2),

              ]),
            ),
          ),

         if(showFooter) const FooterWebWidget(footerType: FooterType.nonSliver),

        ],
      ),
    );
  }
}
