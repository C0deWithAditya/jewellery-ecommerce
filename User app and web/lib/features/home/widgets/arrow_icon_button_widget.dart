import 'package:hexacom_user/common/widgets/on_hover.dart';
import 'package:flutter/material.dart';

class ArrowIconButtonWidget extends StatelessWidget {
  final bool isRight;
  final void Function()? onTap;
  const ArrowIconButtonWidget({Key? key, this.isRight = true, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 40, width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: OnHover(child: Icon(isRight ? Icons.arrow_forward : Icons.arrow_back, color: Theme.of(context).primaryColor, size: 25)),
      ),
    );
  }
}
