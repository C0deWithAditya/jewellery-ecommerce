import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/userinfo_model.dart';
import 'package:hexacom_user/common/widgets/custom_alert_dialog_widget.dart';
import 'package:hexacom_user/features/auth/domain/models/social_login_model.dart';
import 'package:hexacom_user/features/auth/domain/enums/social_login_options_enum.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/auth/widgets/existing_account_bottom_sheet.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class SocialLoginWidget extends StatefulWidget {
  const SocialLoginWidget({super.key});

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  SocialLoginModel socialLogin = SocialLoginModel();

  void route(bool isRoute, String? token, String? errorMessage, String? tempToken, UserInfoModel? userInfoModel, String? socialLoginMedium, String? email, String? name) async {
    if (isRoute) {
      if(token != null){
        RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
      }else if(tempToken != null){
        RouteHelper.getOtpRegistrationScreen(context, tempToken, email ?? '', userName: name ?? '', action: RouteAction.push);

      } else if(userInfoModel != null){
        ResponsiveHelper.showDialogOrBottomSheet(
          context,
          CustomAlertDialogWidget(
            // width: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.width * 0.3 : null,
            child: ExistingAccountBottomSheet(userInfoModel: userInfoModel, socialLoginMedium: socialLoginMedium!, socialUserName: name ?? '',),
          ),
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? ''), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? ''), backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {

    final ConfigModel configModel = context.read<SplashProvider>().configModel!;

    return Consumer<AuthProvider>(builder: (context, authProvider, _) {

      if(authProvider.countSocialLoginOptions == 1){
        return Row(children: [

          if(AuthHelper.isGoogleLoginEnable(configModel))
            Expanded(child: InkWell(
              onTap: () async {
                try{

                  if(authProvider.googleAccount != null){
                    await authProvider.googleSignOut();
                  }

                  GoogleSignInAuthentication  auth = await authProvider.googleLogin();
                  GoogleSignInAccount googleAccount = authProvider.googleAccount!;

                  authProvider.socialLogin(
                    SocialLoginModel(
                      email: googleAccount.email, token: auth.accessToken, uniqueId: googleAccount.id, medium: SocialLoginOptionsEnum.google.name,
                      name: googleAccount.displayName,
                    ),
                    route,
                  );
                }catch(er){
                  debugPrint('access token error is : $er');
                }
              },
              child: SocialButtonView(
                text: getTranslated('continue_with_google', context),
                image: Images.google,
              ),

            )),

          if(AuthHelper.isFacebookLoginEnable(configModel))
            Expanded(child: InkWell(
              onTap: () async{
                LoginResult result = await FacebookAuth.instance.login();

                if (result.status == LoginStatus.success) {
                  Map userData = await FacebookAuth.instance.getUserData();


                  authProvider.socialLogin(
                    SocialLoginModel(
                      email: userData['email'], token: result.accessToken!.token, uniqueId: result.accessToken!.userId,
                      medium: SocialLoginOptionsEnum.facebook.name,
                      name: userData['name'],
                    ), route,
                  );
                }
              },
              child: SocialButtonView(
                text: getTranslated('continue_with_facebook', context),
                image: Images.facebookSocial,
              ),
            ),),

          if(AuthHelper.isAppleLoginEnable(configModel))
            Expanded(
              child: InkWell(
                onTap: () async {
                  final credential = await SignInWithApple.getAppleIDCredential(scopes: [
                    AppleIDAuthorizationScopes.email,
                    AppleIDAuthorizationScopes.fullName,
                  ],
                    webAuthenticationOptions: WebAuthenticationOptions(
                      clientId: '${configModel.appleLogin?.clientId}',
                      redirectUri: Uri.parse(AppConstants.baseUrl),
                    ),
                  );
                  authProvider.socialLogin(SocialLoginModel(
                      email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode, medium: SocialLoginOptionsEnum.apple.name,
                      name: credential.givenName ?? credential.familyName
                  ), route);
                },
                child: SocialButtonView(
                  text: getTranslated('continue_with_apple', context),
                  image: Images.appleLogo,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
        ]);
      }

      else if(authProvider.countSocialLoginOptions == 2){
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [

          if(AuthHelper.isGoogleLoginEnable(configModel))...[
            Expanded(child: InkWell(
              onTap: () async {
                try{

                  // if(authProvider.googleAccount != null){
                  //   await authProvider.googleSignOut();
                  // }

                  GoogleSignInAuthentication  auth = await authProvider.googleLogin();
                  GoogleSignInAccount googleAccount = authProvider.googleAccount!;


                  authProvider.socialLogin(SocialLoginModel(
                    email: googleAccount.email, token: auth.accessToken, uniqueId: googleAccount.id, medium: SocialLoginOptionsEnum.google.name,
                    name : googleAccount.displayName,
                  ), route);


                }catch(er){
                  debugPrint('access token error is : $er');
                }
              },
              child: SocialButtonView(
                text: getTranslated('google', context),
                image: Images.google,
              ),

            )),
            const SizedBox(width: Dimensions.paddingSizeDefault),
          ],

          if(AuthHelper.isFacebookLoginEnable(configModel))...[

            Expanded(child: InkWell(
              onTap: () async{

                LoginResult result = await FacebookAuth.instance.login();
                if (result.status == LoginStatus.success) {
                  Map userData = await FacebookAuth.instance.getUserData();

                  authProvider.socialLogin(
                    SocialLoginModel(
                      email: userData['email'],
                      token: result.accessToken!.token,
                      uniqueId: result.accessToken!.userId,
                      medium: SocialLoginOptionsEnum.facebook.name,
                      name: userData['name'],
                    ), route,
                  );
                }
              },
              child: SocialButtonView(
                text: getTranslated('facebook', context),
                image: Images.facebookSocial,
              ),
            )),
            AuthHelper.isAppleLoginEnable(configModel) ? const SizedBox(width: Dimensions.paddingSizeDefault) : const SizedBox.shrink(),
          ],

          if(AuthHelper.isAppleLoginEnable(configModel))...[
            Expanded(
              child: InkWell(
                onTap: () async {
                  final credential = await SignInWithApple.getAppleIDCredential(scopes: [
                    AppleIDAuthorizationScopes.email,
                    AppleIDAuthorizationScopes.fullName,
                  ],
                    webAuthenticationOptions: WebAuthenticationOptions(
                      clientId: '${configModel.appleLogin?.clientId}',
                      redirectUri: Uri.parse(AppConstants.baseUrl),
                    ),
                  );
                  authProvider.socialLogin(SocialLoginModel(
                      email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode, medium: SocialLoginOptionsEnum.apple.name,
                      name: credential.givenName ?? credential.familyName
                  ), route);
                },
                child: SocialButtonView(
                  text: getTranslated('apple', context),
                  image: Images.appleLogo,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],

        ],);
      }

      else if(authProvider.countSocialLoginOptions == 3){
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [

          if(AuthHelper.isGoogleLoginEnable(configModel))...[
            InkWell(
              onTap: () async {
                try{

                  if(authProvider.googleAccount != null){
                    await authProvider.googleSignOut();
                  }

                  GoogleSignInAuthentication  auth = await authProvider.googleLogin();
                  GoogleSignInAccount googleAccount = authProvider.googleAccount!;

                  authProvider.socialLogin(SocialLoginModel(
                    email: googleAccount.email, token: auth.accessToken, uniqueId: googleAccount.id, medium: SocialLoginOptionsEnum.google.name,
                    name: googleAccount.displayName,
                  ), route);


                }catch(er){
                  debugPrint('access token error is : $er');
                }
              },
              child: const SocialButtonView(
                image: Images.google,
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),

            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],

          if(AuthHelper.isFacebookLoginEnable(configModel))...[
            InkWell(
              onTap: () async{
                LoginResult result = await FacebookAuth.instance.login();

                if (result.status == LoginStatus.success) {
                  Map userData = await FacebookAuth.instance.getUserData();


                  authProvider.socialLogin(
                    SocialLoginModel(
                      email: userData['email'],
                      token: result.accessToken!.token,
                      uniqueId: result.accessToken!.userId,
                      medium: SocialLoginOptionsEnum.facebook.name,
                      name: userData['name'],
                    ), route,
                  );
                }
              },
              child: const SocialButtonView(
                image: Images.facebookSocial,
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],

          if(AuthHelper.isAppleLoginEnable(configModel))...[
            InkWell(
              onTap: () async {
                final credential = await SignInWithApple.getAppleIDCredential(scopes: [
                  AppleIDAuthorizationScopes.email,
                  AppleIDAuthorizationScopes.fullName,
                ],
                  webAuthenticationOptions: WebAuthenticationOptions(
                    clientId: '${configModel.appleLogin?.clientId}',
                    redirectUri: Uri.parse(AppConstants.baseUrl),
                  ),
                );
                authProvider.socialLogin(SocialLoginModel(
                    email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode, medium: SocialLoginOptionsEnum.apple.name,
                    name: credential.givenName ?? credential.familyName
                ), route);
              },
              child: SocialButtonView(
                image: Images.appleLogo,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            ),
          ],

        ],);
      }

      else{
        return Container();
      }


    });
  }
}

class SocialButtonView extends StatelessWidget {
  final String image;
  final String? text;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  const SocialButtonView({
    Key? key, required this.image, this.text, this.color, this.padding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??  const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // border: Border.all(
        //   color: Theme.of(context).cardColor,
        //   width: 1,
        // ),
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0,2),
            blurRadius: 3,
            spreadRadius: 0,
            color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.16)
          ),

          BoxShadow(
              offset: const Offset(0,2),
              blurRadius: 3,
              spreadRadius: 0,
              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.08)
          ),

        ]
      ),
      child:   Row(mainAxisAlignment: MainAxisAlignment.center, children: [

        Image.asset(image, color: color,
          height: ResponsiveHelper.isDesktop(context)
              ? 25 :ResponsiveHelper.isTab(context)
              ? 20 : 15,
          width: ResponsiveHelper.isDesktop(context)
              ? 25 : ResponsiveHelper.isTab(context)
              ? 20 : 15,
        ),

        if(text != null)...[
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(text!, style: rubikSemiBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ))
        ],

      ]),
    );
  }
}
