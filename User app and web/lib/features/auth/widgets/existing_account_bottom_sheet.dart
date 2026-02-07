import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/userinfo_model.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_mask_info.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class ExistingAccountBottomSheet extends StatefulWidget {
  final UserInfoModel userInfoModel;
  final String socialLoginMedium;
  final String socialUserName;
  const ExistingAccountBottomSheet({
    super.key,
    required this.userInfoModel,
    required this.socialLoginMedium,
    required this.socialUserName
  });


  @override
  State<ExistingAccountBottomSheet> createState() => _ExistingAccountBottomSheetState();
}

class _ExistingAccountBottomSheetState extends State<ExistingAccountBottomSheet> {
  @override
  Widget build(BuildContext context) {

    final ConfigModel? configModel = context.read<SplashProvider>().configModel;
    final Size size = MediaQuery.of(context).size;

    print("--------------------------(EXISTING ACCOUNT)---------------UserInfoModel : ${widget.userInfoModel.toJson()} and Medium : ${widget.socialLoginMedium} and UserName : ${widget.socialUserName}");

    return Column(mainAxisSize: MainAxisSize.min, children: [

      SizedBox(height: ResponsiveHelper.isDesktop(context) ? size.height * 0.08 : size.height * 0.015),

      CircleAvatar(
        radius: size.height * 0.05,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? size.height * 0.1 : 40),
          child: CustomImageWidget(
            image: widget.userInfoModel.image != null ? "${configModel?.baseUrls?.customerImageUrl}/${widget.userInfoModel.image}" : '',
            fit: BoxFit.cover,
            width: size.width,
            height: size.height
          ),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Text("${widget.userInfoModel.fName} ${widget.userInfoModel.lName}",
        style: rubikRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

      Text(getTranslated('is_it_you', context),
        style: rubikRegular.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Padding(padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? size.width * 0.03 : size.height * 0.02),
        child: RichText(textAlign: TextAlign.center, text: TextSpan(children:[

          TextSpan(
            text: getTranslated('it_looks_like_the_email', context),
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor.withOpacity(0.5),
            ),
          ),

          TextSpan(
            text: ' ${CustomMaskInfo.maskedEmail(widget.userInfoModel.email ?? '')} ',
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor,
            ),
          ),

          TextSpan(
            text: getTranslated('already_used_existing_account', context),
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor.withOpacity(0.5),
            ),
          ),

        ])),
      ),
      SizedBox(height: ResponsiveHelper.isDesktop(context) ? size.height * 0.03 : size.height * 0.02),

      Row(children: [

        Expanded(child: Container()),

        Expanded(flex: 3, child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButtonWidget(
                backgroundColor: Theme.of(context).hintColor,
                isLoading: authProvider.isLoading,
                btnTxt: getTranslated('no', context),
                onTap: (){

                  print("----------------------(EXISTING ACCOUNT BOTTOM SHEET)-------Email: ${widget.userInfoModel.email} and Medium: ${widget.socialLoginMedium}");

                  if(!authProvider.isLoading){
                    Navigator.pop(context);
                    authProvider.existingAccountCheck(context, email: widget.userInfoModel.email!, userResponse: 0, medium: widget.socialLoginMedium).then((value){
                      final (responseModel, tempToken) = value;
                      print("--------------- EXISTING API RESPONSE - Message is ${responseModel?.message}");
                      if(responseModel != null && responseModel.isSuccess && responseModel.message == 'tempToken'){
                        // Navigator.pushReplacementNamed(
                        //   Get.context!,
                        //   RouteHelper.getOtpRegistration(tempToken, widget.userInfoModel.email!, userName: widget.socialUserName),
                        // );

                        RouteHelper.getOtpRegistrationScreen(context, tempToken, widget.userInfoModel.email!, userName: widget.socialUserName, action: RouteAction.pushReplacement);

                      }
                    });
                  }

                },
              );
            }
        )),

        Expanded(child: Container()),

        Expanded(flex: 3,child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButtonWidget(
                isLoading: authProvider.isLoading,
                btnTxt: getTranslated('yes_its_me', context),
                onTap: (){

                  print("----------------------(EXISTING ACCOUNT BOTTOM SHEET)-------Email: ${widget.userInfoModel.email} and Medium: ${widget.socialLoginMedium}");

                  if(!authProvider.isLoading){
                    Navigator.pop(context);
                    authProvider.existingAccountCheck(context, email: widget.userInfoModel.email!, userResponse: 1, medium: widget.socialLoginMedium).then((value){
                      final (responseModel, tempToken) = value;
                      print("--------------- EXISTING API RESPONSE - Message is ${responseModel?.message}");
                      if(responseModel != null && responseModel.isSuccess && responseModel.message == 'token') {
                        // authProvider.saveUserNumberAndPassword(
                        //   UserLogData(
                        //     phoneNumber: widget.userInfoModel.phone,
                        //     email: widget.userInfoModel.email,
                        //     password: null,
                        //   ),
                        // );
                        // Navigator.pushNamedAndRemoveUntil(Get.context!, RouteHelper.getMainRoute(), (route) => false);
                        RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);

                      }
                    });
                  }
                },
              );
            }
        )),

        Expanded(child: Container()),

      ],),
      SizedBox(height: ResponsiveHelper.isDesktop(context) ? size.height * 0.04 : Dimensions.paddingSizeLarge),


    ],);
  }
}