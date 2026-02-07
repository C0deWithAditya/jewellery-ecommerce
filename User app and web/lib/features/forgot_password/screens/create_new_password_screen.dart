import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/helper/email_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:provider/provider.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String? resetToken;
  final String? userInput;
  const CreateNewPasswordScreen({super.key, required this.resetToken, required this.userInput});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  String? userInput;
  bool isPhone = false;


  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    isPhone = EmailCheckerHelper.isNotValid(widget.userInput ?? '');
    userInput = widget.userInput;
    print("-----------------------(CREATE NEW PASSWORD)----------${widget.resetToken} and ${widget.userInput}");
    if(!userInput!.contains('+') && isPhone) {
      userInput = '+${widget.userInput?.replaceAll(' ', '')}';
    }


    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) : CustomAppBarWidget(title: getTranslated('create_new_password', context))) as PreferredSizeWidget?,
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return CustomScrollView(slivers: [

            if(ResponsiveHelper.isDesktop(context))...[
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.04))
            ],

            SliverToBoxAdapter(child: Center(child: Container(
              width: size.width > 700 ? 500 : size.width,
              padding: size.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
              decoration: size.width > 700 ? BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
              ) : null,
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                const SizedBox(height: 55),
                Image.asset(Images.changePasswordBackground,
                  width: 142, height: 142,
                ),
                    const SizedBox(height: 40),
                    Center(
                        child: Text(
                          getTranslated('enter_password_to_create', context),
                          textAlign: TextAlign.center,
                          style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // for password section

                          const SizedBox(height: 60),
                          Text(
                            getTranslated('new_password', context),
                            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomTextFieldWidget(
                            hintText: getTranslated('password_hint', context),
                            isShowBorder: true,
                            isPassword: true,
                            focusNode: _passwordFocus,
                            nextFocus: _confirmPasswordFocus,
                            isShowSuffixIcon: true,
                            inputAction: TextInputAction.next,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          // for confirm password section
                          Text(
                            getTranslated('confirm_password', context),
                            style: rubikMedium.copyWith(color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomTextFieldWidget(
                            hintText: getTranslated('password_hint', context),
                            isShowBorder: true,
                            isPassword: true,
                            isShowSuffixIcon: true,
                            focusNode: _confirmPasswordFocus,
                            controller: _confirmPasswordController,
                            inputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 24),

                          Center(child: SizedBox(
                            width: ResponsiveHelper.isDesktop(context) ? 300 : null,
                            child: CustomButtonWidget(
                              isLoading: auth.isForgotPasswordLoading,
                              btnTxt: getTranslated('save', context),
                              onTap: () {
                                String password = _passwordController.text.trim() ?? '';
                                String confirmPassword = _confirmPasswordController.text.trim() ?? '';
                                if (password.isEmpty) {
                                  showCustomSnackBar(getTranslated('enter_password', context), context);
                                } else if(password.length < 6) {
                                  showCustomSnackBar(getTranslated('password_should_be', context), context);
                                } else if (confirmPassword.isEmpty) {
                                  showCustomSnackBar(getTranslated('enter_confirm_password', context), context);
                                } else if (password != confirmPassword) {
                                  showCustomSnackBar(getTranslated('password_did_not_match', context), context);
                                } else {

                                  bool isNumber = EmailCheckerHelper.isNotValid(userInput ?? '');

                                  String type = isNumber ? VerificationType.phone.name : VerificationType.email.name;
                                  auth.resetPassword(userInput, widget.resetToken, password, confirmPassword, type: type).then((value) {
                                    if (value.isSuccess) {
                                      showCustomSnackBar(value.message ?? '', isError: false, context);
                                      RouteHelper.getLoginRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
                                    } else {
                                      showCustomSnackBar(value.message!, context);
                                    }
                                  });

                                }
                              },
                            ),
                          )),


                        ],
                      ),
                    )
                  ],
                ),
            ))),

            if(ResponsiveHelper.isDesktop(context))...[
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02))
            ],

            if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
              hasScrollBody: false,
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [

                SizedBox(height: Dimensions.paddingSizeLarge),
                FooterWebWidget(footerType: FooterType.nonSliver),

              ]),
            ),

          ]);
        },
      ),
    );
  }
}
