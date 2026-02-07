import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';


class PhoneNumberCheckerHelper{

  static RegExp phoneNumberExp = RegExp(r'^-?[0-9]+$');
  static RegExp wordsAndSpecialCharacters = RegExp(r'[A-Za-z!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\s]');

  static bool isValidPhone (String phone){
    return phoneNumberExp.hasMatch(phone);
  }

  static String? getPhoneNumber(String phoneNumberWithCountryCode, String countryCode){
    String phoneNumber = phoneNumberWithCountryCode.split(countryCode).last;
    return phoneNumber;
  }


  static bool isPhoneValidWithCountryCode (String numberWithCountryCode) {
    log("Phone number that will be parsed : $numberWithCountryCode");
    bool isValid = false;
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(numberWithCountryCode);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      return isValid;
    } catch (e) {
      log('Phone Number is not parsing: $e');
      return isValid;
    }
  }


  static String? getCountryCode (String? number) {
    String? countryCode = '';
    try{
      PhoneNumber phoneNumber = PhoneNumber.parse(number ?? '');
      countryCode = phoneNumber.countryCode;
    }catch(error){
      debugPrint('country error: $error');
    }

    return '+${countryCode?.replaceAll('+', '')}';
  }

}