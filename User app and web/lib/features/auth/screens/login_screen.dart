import 'package:country_code_picker/country_code_picker.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/from_page_enum.dart';
import 'package:hexacom_user/features/auth/domain/enums/verification_type_enum.dart';
import 'package:hexacom_user/features/auth/domain/models/user_log_data.dart';
import 'package:hexacom_user/features/auth/screens/only_social_login_widget.dart';
import 'package:hexacom_user/features/auth/screens/send_otp_screen.dart';
import 'package:hexacom_user/features/auth/widgets/social_login_widget.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/phone_number_checker_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_shadow_widget.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FocusNode _emailNumberFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController? _emailOrPhoneController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;
  String? _countryDialCode;
  bool _countryCodeFromConfig = false;

  @override
  void initState() {
    super.initState();

    final AuthProvider authProvider = context.read<AuthProvider>();
    final SplashProvider splashProvider = context.read<SplashProvider>();

    authProvider.setCountSocialLoginOptions(isReload: true);
    int count = AuthHelper.countSocialLoginOptions(splashProvider.configModel);
    authProvider.setCountSocialLoginOptions(count: count, isReload: false);

    _formKeyLogin = GlobalKey<FormState>();
    _emailOrPhoneController = TextEditingController();
    _passwordController = TextEditingController();

    authProvider.toggleIsNumberLogin(value: false, isUpdate: false);

    UserLogData? userData = authProvider.getUserData();
    print("------------USER DATA---------------${userData?.toJson()}");

    _emailNumberFocus.addListener(() {
      setState(() {});
    });

    if(userData != null && userData.loginType == FromPage.login.name) {
      if(userData.phoneNumber != null){
        _emailOrPhoneController!.text = PhoneNumberCheckerHelper.getPhoneNumber(userData.phoneNumber ?? '', userData.countryCode ?? '') ?? '';
        authProvider.toggleIsNumberLogin(value: true, isUpdate: false);
        print("--------------------IS Number Login-----------------${authProvider.isNumberLogin}");
        _countryDialCode ??= userData.countryCode;
        print("--------------------Country CODE---------------- ${userData.countryCode}");
      }else if(userData.email != null){
        _emailOrPhoneController!.text = userData.email ?? '';
      }
      _passwordController?.text = userData.password ?? '';
    }else{
      _countryCodeFromConfig = true;
      _countryDialCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!).dialCode;
    }

    _emailNumberFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailOrPhoneController!.dispose();
    _passwordController!.dispose();
    _emailNumberFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Selector<SplashProvider, ConfigModel?>(
      selector: (ctx, splashProvider)=> splashProvider.configModel,
      builder: (context, configModel, _){

        if(_countryCodeFromConfig) {
          _countryDialCode = CountryCode.fromCountryCode(configModel?.countryCode ?? '').dialCode;
        }


        if(!AuthHelper.isManualLoginEnable(configModel) && !AuthHelper.isOtpLoginEnable(configModel)){
          return const OnlySocialLoginWidget();
        }else if(!AuthHelper.isManualLoginEnable(configModel)){
          return const SendOtpScreen();
        }else{
          return CustomPopScopeWidget(
            child: Scaffold(
              backgroundColor: ResponsiveHelper.isDesktop(context) ? null :  Theme.of(context).cardColor,
              appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) : null,
              body: SafeArea(child: CustomScrollView(slivers: [
                SliverToBoxAdapter(child: Center(
                  child: Consumer<SplashProvider>(builder: (context, splashProvider, _){
                    return  SizedBox(
                      width: ResponsiveHelper.isDesktop(context) ? 450 : null,
                      height: ResponsiveHelper.isDesktop(context) ? null : MediaQuery.sizeOf(context).height,
                      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [

                        if(ResponsiveHelper.isDesktop(context))...[
                          SizedBox(height: size.height * 0.04)
                        ],

                        Center(child: CustomShadowWidget(
                          boxShadow: ResponsiveHelper.isDesktop(context) ? BoxShadow(
                              offset: const Offset(0,10),
                              blurRadius: 30,
                              spreadRadius: 0,
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.07)
                          ): null,
                          shadowColor: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).cardColor : null,
                          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 50 : Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeLarge),
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) => Form(
                              key: _formKeyLogin,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SizedBox(height: 30),
                                  !ResponsiveHelper.isDesktop(context) ? Center(
                                    child: Image.asset(
                                      Images.logo,
                                      height: ResponsiveHelper.isDesktop(context) ? 100.0 : 80,
                                      fit: BoxFit.scaleDown,
                                      matchTextDirection: true,
                                    ),
                                  ): const SizedBox.shrink(),
                                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? size.height * 0.03 :  Dimensions.paddingSizeSmall),
                                  Center(child: Text(getTranslated('login', context), style: rubikMedium.copyWith(
                                    fontSize: Dimensions.fontSizeOverLarge,
                                  ))),
                                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? size.height * 0.04 :  Dimensions.paddingSizeLarge),

                                  Selector<AuthProvider, bool>(
                                    selector: (context, authProvider) => authProvider.isNumberLogin,
                                    builder: (context, isNumberLogin, child) {
                                      return CustomTextFieldWidget(
                                        countryDialCode: isNumberLogin ? _countryDialCode : null,
                                        onCountryChanged: (CountryCode value) {
                                          _countryCodeFromConfig = false;
                                           _countryDialCode = value.dialCode;

                                        },
                                        onChanged: (String text) => AuthHelper.identifyEmailOrNumber(text, context),
                                        hintText: getTranslated('enter_email_phone', context),
                                        title: getTranslated('email_phone', context),
                                        isShowBorder: true,
                                        focusNode: _emailNumberFocus,
                                        nextFocus: _passwordFocus,
                                        controller: _emailOrPhoneController,
                                        inputType: TextInputType.emailAddress,
                                        isShowPrefixIcon: !isNumberLogin,
                                        prefixAssetUrl: Images.emailPhoneIcon,
                                        prefixAssetImageColor: Theme.of(context).hintColor,

                                      );
                                    },
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),


                                  CustomTextFieldWidget(

                                    hintText: getTranslated('6+character', context),
                                    title: getTranslated('password', context),
                                    isShowBorder: true,
                                    isPassword: true,
                                    isShowSuffixIcon: true,
                                    isShowPrefixIcon: true,
                                    prefixAssetUrl: Images.password,
                                    focusNode: _passwordFocus,
                                    controller: _passwordController,
                                    inputAction: TextInputAction.done,
                                    prefixAssetImageColor: Theme.of(context).hintColor,

                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),

                                  // for remember me section
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, child) => InkWell(
                                        onTap: ()=> authProvider.toggleRememberMe(),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                  color: authProvider.isActiveRememberMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                                  border:
                                                  Border.all(color: authProvider.isActiveRememberMe ? Colors.transparent : Theme.of(context).primaryColor),
                                                  borderRadius: BorderRadius.circular(3)),
                                              child: authProvider.isActiveRememberMe
                                                  ? const Icon(Icons.done, color: Colors.white, size: 17)
                                                  : const SizedBox.shrink(),
                                            ),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),

                                            Text(
                                              getTranslated('remember_me', context),
                                              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),

                                    InkWell(
                                        onTap: ()=> RouteHelper.getForgetPassRoute(context, action: RouteAction.push),
                                        child: Padding(padding: const EdgeInsets.all(8.0),
                                          child: Text('${getTranslated('forgot_password', context)} ?',
                                            style: rubikRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).colorScheme.error,
                                            ),
                                          ),
                                        )
                                    )

                                  ]),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      authProvider.loginErrorMessage!.isNotEmpty
                                          ? const CircleAvatar(backgroundColor: Colors.red, radius: 5)
                                          : const SizedBox.shrink(),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authProvider.loginErrorMessage ?? "",
                                          style: rubikMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                  // for login button
                                  CustomButtonWidget(
                                    isLoading: authProvider.isLoading,
                                    btnTxt: getTranslated('login', context),
                                    onTap: () async {
                                      final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

                                      String userInput = _emailOrPhoneController?.text.trim() ?? '';
                                      String password = _passwordController?.text.trim() ?? '';


                                      if (userInput.isEmpty) {
                                        showCustomSnackBar(getTranslated('enter_email_or_phone', context), context);
                                      }else if (password.isEmpty) {
                                        showCustomSnackBar(getTranslated('enter_password', context), context);
                                      }else if (password.length < 6) {
                                        showCustomSnackBar(getTranslated('password_should_be', context), context);
                                      }else {

                                        bool isNumber = PhoneNumberCheckerHelper.isValidPhone(userInput);
                                        if(isNumber){
                                          userInput = _countryDialCode! + userInput;
                                        }

                                        String type = isNumber? VerificationType.phone.name : VerificationType.email.name;

                                        await authProvider.login(context, userInput, password, type, fromPage: FromPage.login.name).then((status) async {

                                          if (status.isSuccess) {
                                            if (authProvider.isActiveRememberMe) {
                                              authProvider.saveUserData(UserLogData(
                                                countryCode:  _countryDialCode,
                                                phoneNumber: isNumber ? userInput : null,
                                                email: isNumber ? null : userInput,
                                                password: password,
                                                loginType: FromPage.login.name,
                                              ));
                                            }else {
                                              authProvider.clearUserData();
                                            }
                                            RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
                                          }

                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),

                                  if(AuthHelper.isOtpOrSocialLoginEnable(splashProvider.configModel))...[
                                    Center(child: Text(getTranslated('or', context),
                                      style: rubikRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    )),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),

                                    if(AuthHelper.isOtpLoginEnable(splashProvider.configModel))...[
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                                        Text(getTranslated('login_with', context),
                                          style: rubikRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                        InkWell(
                                          onTap: () => RouteHelper.getSendOtpScreen(context, action: RouteAction.push),
                                          child: Text(getTranslated('otp', context),
                                            style: rubikRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              decoration: TextDecoration.underline,
                                              decorationColor: Theme.of(context).primaryColor,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),

                                      ]),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                    ],

                                    if(AuthHelper.isSocialMediaLoginEnable(splashProvider.configModel)
                                        && ((AuthHelper.isFacebookLoginEnable(splashProvider.configModel)
                                            || AuthHelper.isGoogleLoginEnable(splashProvider.configModel) || AuthHelper.isAppleLoginEnable(splashProvider.configModel))))...[

                                      const Center(child: SocialLoginWidget()),
                                      const SizedBox(height: Dimensions.paddingSizeLarge),
                                    ],
                                  ],

                                  // for create an account

                                  Center(child: InkWell(
                                    onTap: () => RouteHelper.getCreateAccountRoute(context, action: RouteAction.push),
                                    child: RichText(text: TextSpan(children: [
                                      TextSpan(text: getTranslated('do_not_have_an_account', context),  style: rubikRegular.copyWith(
                                        color: Theme.of(context).hintColor.withOpacity(0.8),
                                      )),

                                      TextSpan(text: ' ${getTranslated('sign_up', context)}', style: rubikMedium.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        decoration: TextDecoration.underline,
                                      )),

                                    ])),
                                  )),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  if(!ResponsiveHelper.isDesktop(context))...[
                                    Center(child: InkWell(
                                      onTap: ()=> RouteHelper.getDashboardRoute(context, 'home', action: RouteAction.pushReplacement),
                                      child: RichText(text: TextSpan(children: [
                                        TextSpan(text: '${getTranslated('continue_as_a', context)} ',  style: rubikRegular.copyWith(
                                          color: Theme.of(context).hintColor.withOpacity(0.8),
                                        )),

                                        TextSpan(text: getTranslated('guest', context), style: rubikMedium.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          decoration: TextDecoration.underline,
                                        )),

                                      ])),
                                    )),
                                  ],

                                  if(ResponsiveHelper.isDesktop(context))...[
                                    SizedBox(height: size.height * 0.02),
                                  ],


                                ],
                              ),
                            ),
                          ),
                        )),

                        if(ResponsiveHelper.isDesktop(context))...[
                          SizedBox(height: size.height * 0.02),
                        ],

                      ]),
                    );
                  }),
                )),

                if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [

                    SizedBox(height: Dimensions.paddingSizeLarge),
                    FooterWebWidget(footerType: FooterType.nonSliver),

                  ]),
                ),





              ])),
            ),
          );
        }
      },
    );




  }
}
