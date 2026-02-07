import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/enums/app_mode.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_mask_info.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/domain/models/user_log_data.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/email_checker_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_directionality_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  final String userInput;
  final String fromPage;
  final String? session;
  const VerificationScreen({super.key, this.session, required this.userInput, required this.fromPage});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController inputPinTextController = TextEditingController();
  bool isPhone = false;
  String? userInput;

  @override
  void initState() {
    final VerificationProvider verificationProvider = Provider.of<VerificationProvider>(context, listen: false);
    verificationProvider.startVerifyTimer();
    verificationProvider.updateVerificationCode('', 6, isUpdate: false);
    isPhone = EmailCheckerHelper.isNotValid(widget.userInput);
    userInput = widget.userInput;

    print("----------------------(VERIFICATION SCREEN)------${widget.userInput} and ${widget.fromPage}");
    print("----------------------(VERIFICATION SCREEN)------$isPhone");
    print("----------------------(VERIFICATION SCREEN)------AFTER MODIFICATION $userInput and ${widget.fromPage}");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    final ConfigModel configModel = context.read<SplashProvider>().configModel!;
    final bool isFirebaseOTP = AuthHelper.isCustomerVerificationEnable(configModel) && AuthHelper.isFirebaseVerificationEnable(configModel);
    final AuthProvider authProvider = context.read<AuthProvider>();

    if(!userInput!.contains('+') && isPhone) {
      userInput = '+${userInput?.replaceAll(' ', '')}';
    }

    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget()) : CustomAppBarWidget(
        title: getTranslated('otp_verification', context),
      )) as PreferredSizeWidget?,
      body: CustomScrollView(slivers: [

        SliverToBoxAdapter(child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Consumer<VerificationProvider>(
          builder: (context, verificationProvider, child) => Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

            SizedBox(height: !ResponsiveHelper.isMobile(context) ? size.height * 0.04 : 0),

            Center(child: Container(
              width: size.width > 700 ? 450 : size.width,
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              padding: size.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
              decoration: size.width > 700 ? BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.07),
                    blurRadius: 30, spreadRadius: 0,
                    offset: const Offset(0,10),
                  )],
              ) : null,
              child: Column(children: [

                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomAssetImageWidget(
                  widget.fromPage == FromPage.forget.name ? Images.forgotVerificationBackground : isPhone ? Images.phoneVerificationBackgroundIcon : Images.emailVerificationBackgroundIcon,
                  height: 120,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Center(child: Text(
                    '${getTranslated('we_have_sent_verification_code', context)} ${isPhone ? CustomMaskInfo.maskedPhone(userInput!) : CustomMaskInfo.maskedEmail(userInput!)}',
                    textAlign: TextAlign.center,
                    style: rubikRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                  )),
                ),

                if(AppMode.demo == AppConstants.appMode)...[
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Text(getTranslated('for_demo_purpose_use', context),
                      style: rubikMedium.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ),
                ],

                Padding(padding:  EdgeInsets.symmetric(horizontal: size.width > 850 ? 20 : 39, vertical: 30),
                  child: PinCodeTextField(
                    length: 6,
                    appContext: context,
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      fieldHeight: 50,
                      fieldWidth: 40,
                      borderWidth: 1,
                      borderRadius: BorderRadius.circular(10),
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.4),
                      selectedFillColor: Colors.white,
                      inactiveFillColor: ColorResources.getSearchBg(context),
                      inactiveColor: Theme.of(context).secondaryHeaderColor,
                      activeColor: Theme.of(context).primaryColor,
                      activeFillColor: ColorResources.getSearchBg(context),
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onChanged: (query) => verificationProvider.updateVerificationCode(query, 6),
                    beforeTextPaste: (text) {
                      return true;
                    },
                  ),
                ),

                if(verificationProvider.isEnableVerificationCode && !verificationProvider.isLoading)...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: SizedBox(
                      width: ResponsiveHelper.isMobile(context) ? Dimensions.webScreenWidth : 300,
                      child: CustomButtonWidget(
                        isLoading: verificationProvider.isLoading || authProvider.isLoading,
                        btnTxt: getTranslated('verify', context),
                        onTap: () {

                          if (widget.fromPage == FromPage.otp.name) {
                            if(isPhone && AuthHelper.isFirebaseVerificationEnable(configModel)){
                              authProvider.firebaseOtpLogin(context,
                                phoneNumber: widget.userInput,
                                session: '${widget.session}',
                                otp: verificationProvider.verificationCode,
                              );
                            }else if(isPhone && AuthHelper.isPhoneVerificationEnable(configModel)){


                              verificationProvider.verifyPhoneForOtp(userInput!, context).then((value){
                                final (responseModel, tempToken) = value;
                                if((responseModel != null && responseModel.isSuccess) && tempToken == null) {

                                  print("-------------------AFTER VERIFY OTP-------------Remember Me : ${authProvider.isActiveRememberMe}");
                                  print("-------------------AFTER VERIFY OTP-------------User Input : $userInput");
                                  print("-------------------AFTER VERIFY OTP-------------Country Code : ${PhoneNumberCheckerHelper.getCountryCode(userInput)!}");

                                  if (authProvider.isActiveRememberMe) {
                                    String userCountryCode = PhoneNumberCheckerHelper.getCountryCode(userInput)!;
                                    print("-------------------AFTER VERIFY OTP-------------Phone : ${PhoneNumberCheckerHelper.getPhoneNumber(userInput!, userCountryCode)}");
                                    authProvider.saveUserData(UserLogData(
                                      countryCode:  userCountryCode,
                                      phoneNumber: PhoneNumberCheckerHelper.getPhoneNumber(userInput ?? '', userCountryCode),
                                      email: null,
                                      password: null,
                                      loginType: FromPage.otp.name,
                                    ));
                                  } else {
                                    authProvider.clearUserData();
                                  }
                                  RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);

                                }else if((responseModel != null && responseModel.isSuccess) && tempToken != null){

                                  if(ResponsiveHelper.isDesktop(context)){
                                    RouteHelper.getOtpRegistrationScreen(context, tempToken, userInput!, action: RouteAction.push);
                                  }else{
                                    RouteHelper.getOtpRegistrationScreen(context, tempToken, userInput!, action: RouteAction.pushReplacement);
                                  }

                                }

                              });
                            }
                          }else if (widget.fromPage == FromPage.login.name) {
                            if(AuthHelper.isCustomerVerificationEnable(configModel)){
                              if(isPhone && isFirebaseOTP){
                                authProvider.firebaseOtpLogin(context,
                                  phoneNumber: userInput ?? '',
                                  session: '${widget.session}',
                                  otp: verificationProvider.verificationCode,
                                );
                              }else if(isPhone && AuthHelper.isPhoneVerificationEnable(configModel)){
                                print("-----------------------(Verification Screen)---------------UserInput: $userInput");
                                verificationProvider.verifyVerificationCode(context, emailOrPhone: userInput!.trim(), verificationType: VerificationType.phone).then((value) {

                                  if (value.isSuccess) {
                                    if (authProvider.isActiveRememberMe) {
                                      String userCountryCode = PhoneNumberCheckerHelper.getCountryCode(userInput)!;
                                      print("-------------------AFTER VERIFY OTP-------------Phone : ${PhoneNumberCheckerHelper.getPhoneNumber(userInput ?? '', userCountryCode)}");
                                      authProvider.saveUserData(UserLogData(
                                        countryCode:  userCountryCode,
                                        phoneNumber: PhoneNumberCheckerHelper.getPhoneNumber(userInput ?? '', userCountryCode),
                                        email: null,
                                        password: null,
                                        loginType: FromPage.login.name,
                                      ));
                                    } else {
                                      authProvider.clearUserData();
                                    }
                                    RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
                                  }

                                });
                              }else if(!isPhone && AuthHelper.isEmailVerificationEnable(configModel)){
                                print("-----------------------(Verification Screen)---------------UserInput: $userInput");
                                verificationProvider.verifyVerificationCode(context, emailOrPhone: userInput!.trim(), verificationType: VerificationType.email).then((value) {
                                  if (value.isSuccess) {
                                    if (authProvider.isActiveRememberMe) {
                                      authProvider.saveUserData(UserLogData(
                                        countryCode:  null,
                                        phoneNumber: null,
                                        email: userInput,
                                        password: null,
                                        loginType: FromPage.login.name,
                                      ));
                                    }
                                    RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
                                  }
                                });
                              }
                            }
                          }else if(widget.fromPage == FromPage.profile.name){

                            String type = isPhone ? VerificationType.phone.name: VerificationType.email.name;
                            verificationProvider.verifyProfileInfo(context, userInput ?? '', type, widget.session).then((value){
                              if(value.isSuccess) {
                                RouteHelper.getProfileRoute(context, action: RouteAction.pushReplacement);
                              }
                            });

                          }else {
                            if(isFirebaseOTP && isPhone) {
                              authProvider.firebaseOtpLogin(context,
                                phoneNumber: userInput ?? '',
                                session: '${widget.session}',
                                otp: verificationProvider.verificationCode,
                                isForgetPassword: true,
                              );
                            }else{
                              verificationProvider.verifyToken(widget.userInput).then((value) {
                                if(value.isSuccess) {
                                  print("-----(VERIFICATION SCREEN)--------UserInput : ${widget.userInput} and VerificationCode: ${verificationProvider.verificationCode}");

                                  //RouteHelper.getNewPassRoute(widget.userInput, verificationProvider.verificationCode, action: RouteAction.pushReplacement);
                                  RouteHelper.getNewPassRoute(context, widget.userInput, verificationProvider.verificationCode, action: RouteAction.push);

                                }else {
                                  showCustomSnackBar(value.message!, context);
                                }
                              });
                            }

                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],

                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [

                  Text(getTranslated('did_not_receive_the_code', context), style: rubikMedium.copyWith(
                    color: rubikMedium.color?.withOpacity(.6),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),


                  verificationProvider.isLoading ? const CircularProgressIndicator() : TextButton(
                      onPressed: verificationProvider.currentTime! > 0 ? null :  () async {

                        if(widget.fromPage != FromPage.forget.name){
                          await verificationProvider.sendVerificationCode(context, configModel,
                                    userInput ?? '', type: isPhone ? VerificationType.phone.name : VerificationType.email.name, fromPage: widget.fromPage
                                );
                              }else{
                                bool isNumber = EmailCheckerHelper.isNotValid(userInput ?? '');
                                if(isNumber && isFirebaseOTP){
                                  verificationProvider.firebaseVerifyPhoneNumber(context, userInput ?? '', widget.fromPage, isForgetPassword: true);
                                }else{
                                  await authProvider.forgetPassword(userInput ?? '', isNumber? VerificationType.phone.name : VerificationType.email.name,
                                  ).then((value) {

                                    verificationProvider.startVerifyTimer();
                                    if (value.isSuccess) {
                                      showCustomSnackBar(getTranslated('resend_code_successful', context), context, isError: false);
                                    } else {
                                      showCustomSnackBar(value.message!, context);
                                    }

                                  });
                                }
                              }


                            },
                            child: Builder(
                                builder: (context) {
                                  int? days, hours, minutes, seconds;

                                  Duration duration = Duration(seconds: verificationProvider.currentTime ?? 0);
                                  days = duration.inDays;
                                  hours = duration.inHours - days * 24;
                                  minutes = duration.inMinutes - (24 * days * 60) - (hours * 60);
                                  seconds = duration.inSeconds - (24 * days * 60 * 60) - (hours * 60 * 60) - (minutes * 60);

                                  return CustomDirectionalityWidget(
                                    child: Text((verificationProvider.currentTime != null && verificationProvider.currentTime! > 0)
                                        ? '${getTranslated('resend', context)} (${minutes > 0 ? '${minutes}m :' : ''}${seconds}s)'
                                        : getTranslated('resend_it', context), textAlign: TextAlign.end,
                                        style: rubikMedium.copyWith(
                                          color: verificationProvider.currentTime != null && verificationProvider.currentTime! > 0 ?
                                          Theme.of(context).disabledColor : Theme.of(context).primaryColor.withOpacity(.6),
                                        )),
                                  );
                                }
                            )),
                      ],
                    ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

              ],),
            )),

            SizedBox(height: !ResponsiveHelper.isMobile(context) ? size.height * 0.04 : 0),

          ]),

        )))),
        const FooterWebWidget(footerType: FooterType.sliver),

      ]),
    );
  }
}
