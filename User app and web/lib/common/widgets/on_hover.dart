
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:flutter/material.dart';

class OnHover extends StatelessWidget {
  final Widget? child;
  final bool isItem;
  const OnHover({super.key, this.child, this.isItem = false});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isWeb() ? _OnHoverView(isItem: isItem, child: child) : child!;
  }
}

class _OnHoverView extends StatefulWidget {
  final Widget? child;
  final bool isItem;
  const _OnHoverView({this.child, this.isItem = false});

  @override
  State<_OnHoverView> createState() => _OnHoverViewState();

}

class _OnHoverViewState extends State<_OnHoverView> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    final hoverTransformed = Matrix4.identity()..scale(1.05, 1.03);
    final transform = isHovered ? hoverTransformed : Matrix4.identity();
    final shedow1 = BoxDecoration(
      // shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 3),
        )
      ],
    );
    final shedow2 = BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0),
          blurRadius: 0,
          offset: const Offset(0, 0),
        )
      ],
    );
    return MouseRegion(
      onEnter: (event) => onEntered(true),
      onExit: (event) => onEntered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: widget.isItem ? isHovered ? shedow1 : shedow2 : shedow2,
        transform: widget.isItem ? Matrix4.identity() : transform  ,
        child: widget.child,
      ),
    );
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }
}

