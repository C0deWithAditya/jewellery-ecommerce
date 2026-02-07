import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/enums/html_type_enum.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatelessWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({Key? key, required this.htmlType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    final policyModel = Provider.of<SplashProvider>(context, listen: false).policyModel;

    String data = 'no_data_found';
    String appBarText = '';

    switch (htmlType) {
      case HtmlType.termsAndCondition :
        data = configModel!.termsAndConditions ?? '';
        appBarText = 'terms_and_condition';
      break;
      case HtmlType.aboutUs :
        data = configModel!.aboutUs ?? '';
        appBarText = 'about_us';
      break;
      case HtmlType.privacyPolicy :
        data = configModel!.privacyPolicy ?? '';
        appBarText = 'privacy_policy';
      break;
      case HtmlType.cancellationPolicy :
        data = policyModel!.cancellationPage!.content ?? '';
        appBarText = 'cancellation_policy';
      break;
      case HtmlType.refundPolicy :
        data = policyModel!.refundPage!.content ?? '';
        appBarText = 'refund_policy';
      break;
      case HtmlType.returnPolicy :
        data = policyModel!.returnPage!.content ?? '';
        appBarText = 'return_policy';
      break;
    }

    if(data.isNotEmpty) {
      data = data.replaceAll('href=', 'target="_blank" href=');
    }


    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated(appBarText, context)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Center(child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Column(children: [
              if(ResponsiveHelper.isDesktop(context)) Container(
                height: 100, alignment: Alignment.center,
                child: SelectableText(getTranslated(appBarText, context),
                  style: rubikBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: 30),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault),
                child: HtmlWidget(
                  data, key: Key(htmlType.toString()),
                  onTapUrl: (String url)=> launchUrlString(url, mode: LaunchMode.externalApplication),
                ),
              ),
              const SizedBox(height: 30),
            ]),
          ))),

          const FooterWebWidget(footerType: FooterType.sliver),
        ],
      ),
    );


  }
}


