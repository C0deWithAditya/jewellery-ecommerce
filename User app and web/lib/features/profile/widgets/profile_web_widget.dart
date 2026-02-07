
import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/models/userinfo_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileWebWidget extends StatefulWidget {
  final FocusNode? firstNameFocus;
  final FocusNode? lastNameFocus;
  final FocusNode? emailFocus;
  final FocusNode? phoneNumberFocus;
  final FocusNode? passwordFocus;
  final FocusNode? confirmPasswordFocus;
  final TextEditingController? firstNameController;
  final TextEditingController? lastNameController;
  final TextEditingController? emailController;
  final TextEditingController? phoneNumberController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  final UserInfoModel? userInfo;

  final Function pickImage;
  final XFile? file;
  const ProfileWebWidget({
    super.key,
    required this.firstNameFocus,
    required this.lastNameFocus,
    required this.emailFocus,
    required this.phoneNumberFocus,
    required this.passwordFocus,
    required this.confirmPasswordFocus,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.passwordController,
    required this.confirmPasswordController,
    //function
    required this.pickImage,
    //file
    required this.file, required this.userInfo


  });

  @override
  State<ProfileWebWidget> createState() => _ProfileWebWidgetState();
}

class _ProfileWebWidgetState extends State<ProfileWebWidget> {
  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final VerificationProvider verificationProvider = context.read<VerificationProvider>();
    final phoneToolTipKey = GlobalKey<State<Tooltip>>();
    final emailToolTipKey = GlobalKey<State<Tooltip>>();

    return SingleChildScrollView(
      child: Column(children: [
        Consumer<ProfileProvider>(builder: (context, profileProvider, child) {
          return Center(child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Stack(children: [

              Column(children: [

                Container(height: 150,  color:  Theme.of(context).primaryColor,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 240.0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                    profileProvider.userInfoModel != null ? Text(
                      '${profileProvider.userInfoModel?.fName ?? ''} ${profileProvider.userInfoModel?.lName ?? 'nnn'}',
                      style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.white),
                    ) : const SizedBox(height: Dimensions.paddingSizeDefault, width: 150),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    profileProvider.userInfoModel != null ? Text(
                      profileProvider.userInfoModel?.email ?? '666',
                      style: rubikRegular.copyWith(color: Colors.white),
                    ) : const SizedBox(height: 15, width: 100),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                  ]),
                ),
                const SizedBox(height: 100),

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Padding(padding: const EdgeInsets.only(left: 240.0), child: Column(children: [

                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(getTranslated('first_name', context),
                          style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(width: 430,
                          child: CustomTextFieldWidget(
                            hintText: 'John',
                            isShowBorder: true,
                            controller: widget.firstNameController,
                            focusNode: widget.firstNameFocus,
                            nextFocus: widget.lastNameFocus,
                            inputType: TextInputType.name,
                            capitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // for email section

                        SizedBox(width: 430,
                          child: Selector<VerificationProvider, bool>(
                            selector: (context, verificationProvider) => verificationProvider.isLoading,
                            builder: (context, isLoading, child) {
                              return CustomTextFieldWidget(
                                hintText: getTranslated('demo_gmail', context),
                                title: getTranslated('email', context),
                                isShowBorder: true,
                                controller: widget.emailController,
                                isEnabled: true,
                                focusNode: widget.emailFocus,
                                nextFocus: widget.phoneNumberFocus,
                                inputType: TextInputType.emailAddress,
                                isShowSuffixIcon: true,
                                isToolTipSuffix: AuthHelper.isEmailVerificationEnable(splashProvider.configModel) && widget.emailController!.text.isNotEmpty? true : false,
                                toolTipMessage: profileProvider.userInfoModel?.emailVerifiedAt == null ? getTranslated('email_not_verified', context) : '',
                                toolTipKey: emailToolTipKey,
                                suffixAssetUrl: AuthHelper.isEmailVerificationEnable(splashProvider.configModel) && profileProvider.userInfoModel?.emailVerifiedAt == null ? Images.notVerifiedProfileIcon : Images.verifiedProfileIcon,

                                onSuffixTap: (){

                                  if(profileProvider.userInfoModel?.emailVerifiedAt == null){
                                    final VerificationProvider verificationProvider = Provider.of<VerificationProvider>(context, listen: false);
                                    verificationProvider.sendVerificationCode(
                                      context, splashProvider.configModel!, widget.emailController?.text.trim() ?? '', type: VerificationType.email.name, fromPage: FromPage.profile.name,
                                    );
                                  }

                                },

                              );
                            }
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Text(getTranslated('password', context),
                          style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(width: 430,
                          child: CustomTextFieldWidget(
                            hintText: getTranslated('password_hint', context),
                            isShowBorder: true,
                            controller: widget.passwordController,
                            focusNode: widget.passwordFocus,
                            nextFocus: widget.confirmPasswordFocus,
                            isPassword: true,
                            isShowSuffixIcon: true,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(getTranslated('last_name', context),
                          style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(width: 430,
                          child: CustomTextFieldWidget(
                            hintText: 'Doe',
                            isShowBorder: true,
                            controller: widget.lastNameController,
                            focusNode: widget.lastNameFocus,
                            nextFocus: widget.phoneNumberFocus,
                            inputType: TextInputType.name,
                            capitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // for phone Number section
                        Selector<AuthProvider, bool>(
                          selector: (context, authProvider) => authProvider.isNumberLogin,
                          builder: (context, isNumberLogin, child) {
                            final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
                            print("---------------------(IS NUMBER LOGIN)--------------${authProvider.isNumberLogin}");

                            return Selector<VerificationProvider, bool>(
                              selector: (context, verificationProvider) => verificationProvider.isLoading,
                              builder: (context, isLoading, child) {

                                return SizedBox(width: 430,
                                  child: CustomTextFieldWidget(
                                    countryDialCode: isNumberLogin ? profileProvider.countryCode : null,
                                    onCountryChanged: (CountryCode value) => profileProvider.setCountryCode(value.dialCode!),
                                    onChanged: (String text) => AuthHelper.identifyEmailOrNumber(text, context),
                                    title: getTranslated('mobile_number', context),
                                    hintText: getTranslated('number_hint', context),
                                    isShowBorder: true,
                                    isEnabled: profileProvider.userInfoModel?.isPhoneVerified == 0,
                                    controller: widget.phoneNumberController,
                                    isShowSuffixIcon: true,
                                    fillColor: profileProvider.userInfoModel?.isPhoneVerified == 0 ? null : Theme.of(context).hintColor.withOpacity(0.08),
                                    isToolTipSuffix: AuthHelper.isPhoneVerificationEnable(splashProvider.configModel) ? true : false,
                                    focusNode: widget.phoneNumberFocus,
                                    nextFocus: widget.passwordFocus,
                                    inputType: TextInputType.phone,
                                    toolTipMessage: profileProvider.userInfoModel?.isPhoneVerified == 0 ? getTranslated('phone_number_not_verified', context) : getTranslated('cant_update_phone_number',context),
                                    toolTipKey: phoneToolTipKey,
                                    suffixAssetUrl: AuthHelper.isPhoneVerificationEnable(splashProvider.configModel) && profileProvider.userInfoModel?.isPhoneVerified == 0 ? Images.notVerifiedProfileIcon : Images.verifiedProfileIcon,
                                    onSuffixTap: (){

                                      final ConfigModel configModel = context.read<SplashProvider>().configModel!;

                                      String userInput = (profileProvider.countryCode ?? '') + (widget.phoneNumberController?.text.trim() ?? '');
                                      verificationProvider.sendVerificationCode(context, configModel,
                                        userInput, type: VerificationType.phone.name,
                                        fromPage: FromPage.profile.name,
                                      );
                                    },

                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Text(getTranslated('confirm_password', context),
                          style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(width: 430,
                            child: CustomTextFieldWidget(
                              hintText: getTranslated('password_hint', context),
                              isShowBorder: true,
                              controller: widget.confirmPasswordController,
                              focusNode: widget.confirmPasswordFocus,
                              isPassword: true,
                              isShowSuffixIcon: true,
                              inputAction: TextInputAction.done,
                            ),
                          ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                      ]),
                      const SizedBox(height: 55.0)

                    ]),

                    Align(alignment: Alignment.bottomRight, child: Padding(padding: const EdgeInsets.only(right: 20),
                        child: SizedBox(width: 180.0,
                          child: CustomButtonWidget(
                            isLoading: profileProvider.isLoading,
                            btnTxt: getTranslated('update_profile', context),
                            onTap: () async {
                              String firstName = widget.firstNameController?.text.trim() ?? '';
                              String lastName = widget.lastNameController?.text.trim() ?? '';
                              String email = widget.emailController?.text.trim() ?? '';
                              String phoneNumber = '';
                              if(!profileProvider.countryCode!.contains('+')){
                               phoneNumber = '+${profileProvider.countryCode}${widget.phoneNumberController?.text.trim() ?? ''}';
                              }else{
                                phoneNumber = '${profileProvider.countryCode}${widget.phoneNumberController?.text.trim() ?? ''}';
                              }

                              print('--------------(Profile)--------------$phoneNumber');
                              print('--------------(Profile)--------------${profileProvider.countryCode}');
                              print('--------------(Profile)--------------${widget.phoneNumberController?.text.trim() ?? ''}');

                              bool isPhoneValid = PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(phoneNumber);
                              String password = widget.passwordController?.text.trim() ?? '';
                              String confirmPassword = widget.confirmPasswordController?.text.trim() ?? '';

                              if (profileProvider.userInfoModel?.fName == firstName &&
                                  profileProvider.userInfoModel?.lName == lastName &&
                                  profileProvider.userInfoModel?.phone == phoneNumber &&
                                  profileProvider.userInfoModel?.email == widget.emailController?.text
                                  && widget.file == null && password.isEmpty && confirmPassword.isEmpty
                              ) {
                                showCustomSnackBar(getTranslated('change_something_to_update', context), context);

                              }else if (firstName.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_first_name', context), context);

                              }else if (lastName.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_last_name', context), context);

                              }else if (phoneNumber.isEmpty) {
                                showCustomSnackBar(getTranslated('enter_phone_number', context), context);

                              }else if(!isPhoneValid){
                                showCustomSnackBar(getTranslated('invalid_phone_number', context), context);

                              } else if((password.isNotEmpty && password.length < 6) || (confirmPassword.isNotEmpty && confirmPassword.length < 6)) {
                                showCustomSnackBar(getTranslated('password_should_be', context), context);

                              } else if(password != confirmPassword) {
                                showCustomSnackBar(getTranslated('password_did_not_match', context), context);

                              } else {
                                UserInfoModel updateUserInfoModel = UserInfoModel();
                                updateUserInfoModel.fName = firstName;
                                updateUserInfoModel.lName = lastName;
                                updateUserInfoModel.email = email;
                                updateUserInfoModel.phone = phoneNumber;
                                updateUserInfoModel.loginMedium = widget.userInfo?.loginMedium;
                                updateUserInfoModel.image = widget.userInfo?.image;

                                String pass = password;

                                ResponseModel responseModel = await profileProvider.updateUserInfo(
                                  updateUserInfoModel, pass, widget.file,
                                  Provider.of<AuthProvider>(context, listen: false).getUserToken(),
                                );

                                if(responseModel.isSuccess) {
                                  await profileProvider.getUserInfo();
                                  widget.passwordController!.text = '';
                                  widget.confirmPasswordController!.text = '';
                                  showCustomSnackBar(getTranslated('updated_successfully', Get.context!), Get.context!, isError: false);
                                }else {
                                  showCustomSnackBar(responseModel.message, Get.context!);
                                }
                                setState(() {});

                              }},
                          )),
                      )),
                    ]),
                  )),
              ]),
                  Positioned(
                    left: 30,
                    top: 45,
                    child: Stack(
                      children: [
                        Container(
                          height: 180, width: 180,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4),
                              color: ColorResources.getGreyColor(context),image: DecorationImage(image: AssetImage(Images.placeholder(context)),fit: BoxFit.cover),
                              boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 22, offset: const Offset(0, 8.8) )]),
                          child: ClipOval(
                            child: widget.file == null ?
                            profileProvider.userInfoModel == null ?  Image.asset(Images.placeholder(context), height: 170.0, width: 170.0, fit: BoxFit.cover) : FadeInImage.assetNetwork(
                              placeholder: Images.placeholder(context), height: 170, width: 170, fit: BoxFit.cover,
                              image:  '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/'
                                  '${profileProvider.userInfoModel != null ? profileProvider.userInfoModel!.image : ''}',
                              imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 170, width: 170, fit: BoxFit.cover),
                            ) : Image.network(widget.file!.path, height: 170.0, width: 170.0, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                            bottom: 10,
                            right: 10,
                            child: OnHover(
                                child: InkWell(
                                    hoverColor: Colors.transparent,
                                    onTap: widget.pickImage as void Function()?,
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt,color: Colors.white60)))
                            )
                        )],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 55),

        const FooterWebWidget(footerType: FooterType.nonSliver),

      ]),
    );
  }
}