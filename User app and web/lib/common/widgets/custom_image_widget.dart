import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:flutter/cupertino.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.isNotification = false, this.placeholder = ''});

  @override
  Widget build(BuildContext context) {

    return kIsWeb ? Image.network(image, height: height, width: width, fit: fit, errorBuilder: (context, error, stackTrace) {
      return Image.asset(placeholder.isNotEmpty ? placeholder : Images.placeholder(context), height: height, width: width, fit: fit);
    }) : CachedNetworkImage(
      imageUrl: image, height: height, width: width, fit: fit,
      placeholder: (context, url) => Image.asset(placeholder.isNotEmpty ? placeholder : Images.placeholder(context), height: height, width: width, fit: fit),
      errorWidget: (context, url, error) => Image.asset(placeholder.isNotEmpty ? placeholder : Images.placeholder(context), height: height, width: width, fit: fit),
    );

  }
}
