import 'package:hexacom_user/utill/app_constants.dart';
import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFF9675c4),
  secondaryHeaderColor: const Color(0xFFefe6fc),
  brightness: Brightness.dark,
  cardColor: const Color(0xFF29292D),
  hintColor: const Color(0xFFE7F6F8),
  focusColor: const Color(0xFFC3CAD9),
  shadowColor: Colors.black.withOpacity(0.4),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
  dialogTheme: const DialogTheme(surfaceTintColor: Colors.white10),
  colorScheme:  const ColorScheme.dark(
    primary: Color(0xFF9675c4),
    error: Colors.redAccent,
  ),

);
