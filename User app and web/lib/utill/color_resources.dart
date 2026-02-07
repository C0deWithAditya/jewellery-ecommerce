import 'package:flutter/material.dart';
import 'package:hexacom_user/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class ColorResources {
  static Color getGreyColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF6f7275) : const Color(0xFFA0A4A8);
  }
  static Color getGrayColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF919191) : const Color(0xFF6E6E6E);
  }
  static Color getSearchBg(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF585a5c) : const Color(0xFFF4F7FC);
  }
  static Color getBackgroundColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFF343636) : const Color(0xFFF4F7FC);
  }

  static Color getGreyBunkerColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFFE4E8EC) : const Color(0xFF25282B);
  }


  static Color getRatingColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? const Color(0xFFFFBA08) : const Color(0xFFFFBA08);
  }


  static const Color colorGrey = Color(0xFFA0A4A8);
  static const Color colorGreen = Color(0xFF057237);
  static const Color colorBlue = Color(0xFF1692C9);

}
