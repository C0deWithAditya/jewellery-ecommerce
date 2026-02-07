import 'package:hexacom_user/utill/dimensions.dart';
import 'package:flutter/material.dart';

class CustomShadowWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final bool isActive;
  final BoxShadow? boxShadow;
  final Color? shadowColor;
  const CustomShadowWidget({
    super.key, required this.child, this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.borderRadius = Dimensions.radiusSizeDefault,
    this.isActive = true, this.boxShadow, this.shadowColor
  });

  @override
  Widget build(BuildContext context) {
    return isActive ? Container(
      padding: padding ,
      margin:  margin,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius!),
        boxShadow:  [
          boxShadow ?? BoxShadow(offset: const Offset(2, 10), blurRadius: 30, color: shadowColor ??  Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.2)),
        ],
      ),
      child: child,
    ) : child;
  }
}
