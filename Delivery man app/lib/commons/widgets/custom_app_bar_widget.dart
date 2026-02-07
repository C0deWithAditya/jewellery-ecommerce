import 'package:emarket_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:emarket_delivery_boy/utill/dimensions.dart';
import 'package:emarket_delivery_boy/utill/styles.dart';
import 'package:flutter/material.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  const CustomAppBarWidget({super.key, required this.title, this.isBackButtonExist = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color),
        onPressed: () {
          if(Navigator.canPop(context)){
            Navigator.pop(context);
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
          }
        },
      ) : const SizedBox(),
      elevation: 0,
      backgroundColor: Theme.of(context).cardColor,
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}
