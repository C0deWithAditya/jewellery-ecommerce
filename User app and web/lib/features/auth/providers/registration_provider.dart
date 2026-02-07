import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/config_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/models/signup_model.dart';
import 'package:hexacom_user/features/auth/domain/reposotories/auth_repo.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/auth/providers/verification_provider.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/helper/auth_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/enums/from_page_enum.dart';
import '../domain/enums/verification_type_enum.dart';

class RegistrationProvider with ChangeNotifier {
  final AuthRepo? authRepo;

  RegistrationProvider({required this.authRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage = '';
  String? get errorMessage => _errorMessage;

  set setErrorMessage(String? value)=> _errorMessage = value;




  Future<ResponseModel> registration(BuildContext context, SignUpModel signUpModel, ConfigModel config) async {

    final AuthProvider authProvider = Provider.of<AuthProvider>(Get.context!, listen: false);
    final VerificationProvider verificationProvider = Provider.of<VerificationProvider>(Get.context!, listen: false);

    _isLoading = true;
    notifyListeners();

    print('------------(REGISTRATION)-------------- SignUpModel: ${signUpModel.toJson()}');

    ApiResponseModel apiResponse = await authRepo!.registration(signUpModel);
    ResponseModel responseModel;
    String? token;
    String? tempToken;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBar(getTranslated('registration_successful', context), Get.context!, isError: false);

      print("-----------------(REGISTRATION API) Api response : ${apiResponse.response?.data}");
      Map map = apiResponse.response?.data;

      if(map.containsKey('token')){
        token = map["token"];
      }else if(map.containsKey('temporary_token')){
        tempToken = map["temporary_token"];
      }

      if(token != null){
        await authProvider.login(context, signUpModel.phone!, signUpModel.password, VerificationType.phone.name, fromPage : FromPage.registration.name);
        responseModel = ResponseModel(true, 'successful');

      }else{
        String type;
        String userInput;
        if(AuthHelper.isFirebaseVerificationEnable(config) && AuthHelper.isPhoneVerificationEnable(config)){
          type = VerificationType.phone.name;
          userInput = signUpModel.phone!;
        }else if(!AuthHelper.isFirebaseVerificationEnable(config) && AuthHelper.isPhoneVerificationEnable(config)){
          type = VerificationType.phone.name;
          userInput = signUpModel.phone!;
        }else {
          type = VerificationType.email.name;
          userInput = signUpModel.email!;
        }

        verificationProvider.sendVerificationCode(context, config, userInput, type: type, fromPage: FromPage.login.name);
        responseModel = ResponseModel(false, null);
      }

    } else {

      _errorMessage = ApiCheckerHelper.getError(apiResponse).errors?.first.message;
      responseModel = ResponseModel(false, _errorMessage);
    }

    _isLoading = false;
    notifyListeners();

    return responseModel;
  }

}
