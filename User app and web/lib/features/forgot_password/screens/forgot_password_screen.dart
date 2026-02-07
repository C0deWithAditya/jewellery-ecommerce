import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/helper/email_checker_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();

    VerificationProvider verificationProvider = Provider.of<VerificationProvider>(context, listen: false);
    SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    verificationProvider.setVerificationCode = '';
    verificationProvider.setVerificationMessage = '';

    _countryDialCode = CountryCode.fromCountryCode(splashProvider.configModel!.countryCode!).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    final ConfigModel configModel = context.read<SplashProvider>().configModel!;
    final VerificationProvider verificationProvider = context.read<VerificationProvider>();

    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('forgot_password', context)),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Center(
            child: CustomScrollView(
              slivers: [

                SliverToBoxAdapter(child: Column(children: [

                  Center(child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: ResponsiveHelper.isDesktop(context) ? size.height - 400 : size.height,
                    ),
                    child: Container(
                      width: width > 700 ? 450 : width,
                      margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
                      padding: width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
                      decoration: width > 700 ? BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
                      ) : null,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                        const SizedBox(height: 55),

                        Image.asset(
                                  Images.forgotPasswordBackground,
                                  width: 150,
                                  height: 150,
                                ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                          child: Text(getTranslated('no_worries_registered_information_receive_otp', context),
                            textAlign: TextAlign.center,
                            style: rubikRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),

                        Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            const SizedBox(height: 20),
                            ((configModel.forgetPassword?.phone == 1 || configModel.forgetPassword?.firebase == 1) &&
                                configModel.forgetPassword?.email == 1)
                                ? Selector<AuthProvider, bool>(
                              selector: (context, authProvider) => authProvider.isNumberLogin,
                              builder: (context, isNumberLogin, child) {
                                return CustomTextFieldWidget(
                                  countryDialCode: isNumberLogin ? _countryDialCode : null,
                                  onCountryChanged: (CountryCode value) => _countryDialCode = value.dialCode,
                                  onChanged: (String text) => AuthHelper.identifyEmailOrNumber(text, context),
                                  hintText: getTranslated('enter_email_phone', context),
                                  title: getTranslated('email_phone', context),
                                  isShowBorder: true,
                                  controller: _emailOrPhoneController,
                                  inputType: TextInputType.emailAddress,
                                );
                              },
                            ) : ((configModel.forgetPassword?.firebase == 1 || configModel.forgetPassword?.phone == 1))
                                ? Selector<AuthProvider, bool>(
                              selector: (context, authProvider) => authProvider.isNumberLogin,
                              builder: (context, isNumberLogin, child) {
                                return CustomTextFieldWidget(
                                  countryDialCode: isNumberLogin ? _countryDialCode : null,
                                  onCountryChanged: (CountryCode value) => _countryDialCode = value.dialCode,
                                  onChanged: (String text) => AuthHelper.identifyEmailOrNumber(text, context),
                                  hintText: getTranslated('number_hint', context),
                                  title: getTranslated('phone_number', context),
                                  isShowBorder: true,
                                  controller: _emailOrPhoneController,
                                  inputType: TextInputType.phone,
                                );
                              },
                            ) : Selector<AuthProvider, bool>(
                              selector: (context, authProvider) => authProvider.isNumberLogin,
                              builder: (context, isNumberLogin, child) {
                                return CustomTextFieldWidget(
                                  hintText: getTranslated('demo_gmail', context),
                                  title: getTranslated('email', context),
                                  isShowBorder: true,
                                  controller: _emailOrPhoneController,
                                  inputType: TextInputType.emailAddress,
                                );
                              },
                            ),
                                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                                      SizedBox(
                                        width: Dimensions.webScreenWidth,
                                        child: CustomButtonWidget(
                                          isLoading: verificationProvider.isLoading || authProvider.isLoading,
                                          btnTxt: getTranslated('get_otp', context),
                                          onTap: () {
                                            String userInput = _emailOrPhoneController.text.trim();
                                            bool isNumber = EmailCheckerHelper.isNotValid(userInput);
                                            bool isNumberValid = true;

                                            if (isNumber) {
                                              userInput = _countryDialCode! + userInput;
                                              isNumberValid = PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(userInput);
                                            }

                                            print(
                                                "-----------------(Forgot Password)--------UserInput $userInput and $isNumber and $isNumberValid");

                                            if (_emailOrPhoneController.text.isEmpty) {
                                              showCustomSnackBar(getTranslated('enter_email_or_phone', context), context);
                                            } else if (isNumber && !isNumberValid) {
                                              showCustomSnackBar(getTranslated('invalid_phone_number', context), context);
                                            } else {
                                              if (AuthHelper.isFirebaseVerificationEnable(configModel) && isNumber) {
                                                verificationProvider.firebaseVerifyPhoneNumber(context, userInput, FromPage.forget.name, isForgetPassword: true);
                                              } else {
                                                authProvider.forgetPassword(userInput, isNumber ? VerificationType.phone.name : VerificationType.email.name).then((value) {
                                                  if (value.isSuccess) {
                                                    RouteHelper.getVerifyRoute(context, userInput, FromPage.forget.name,
                                                        action: RouteAction.push);
                                                  } else {
                                                    showCustomSnackBar(value.message!, context);
                                                  }
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const FooterWebWidget(footerType: FooterType.nonSliver),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
