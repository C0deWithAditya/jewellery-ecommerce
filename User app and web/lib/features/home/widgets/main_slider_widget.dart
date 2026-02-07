import 'package:carousel_slider/carousel_slider.dart';
import 'package:hexacom_user/features/home/domain/models/banner_model.dart';
import 'package:hexacom_user/features/home/enums/banner_type_enum.dart';
import 'package:hexacom_user/features/home/widgets/main_slider_shimmer_widget.dart';
import 'package:hexacom_user/helper/product_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainSliderWidget extends StatefulWidget {
  final List<BannerModel>? bannerList;
  final BannerType bannerType;
  final bool isMainOnly;
  const MainSliderWidget({Key? key, required this.bannerList, required this.bannerType, this.isMainOnly = false}) : super(key: key);

  @override
  State<MainSliderWidget> createState() => _MainSliderWidgetState();
}

class _MainSliderWidgetState extends State<MainSliderWidget> {


  int currentIndex = 0;



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return widget.bannerList == null ? const  MainSliderShimmerWidget() : widget.bannerList!.isNotEmpty ? Center(
      child: Stack(children: [
        Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
            child: CarouselSlider.builder(
              itemCount: widget.bannerList!.length,
              options: CarouselOptions(
                autoPlayInterval: Duration(milliseconds: widget.bannerType == BannerType.primary ? 4200 : 5320),
                height: ResponsiveHelper.isDesktop(context) ? 380 : (size.width - 32),
                aspectRatio: 1.0,
                enlargeCenterPage: true,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayCurve: Curves.easeInToLinear,
                autoPlayAnimationDuration: Duration(milliseconds: widget.bannerType == BannerType.primary ? 2000 : 3000),
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),

              itemBuilder: (ctx, index, realIdx) {
                return InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                  onTap: ()=> ProductHelper.onTapBannerForRoute(widget.bannerList![index], context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),

                    ),

                    child:  ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                      child: CustomImageWidget(
                        placeholder: widget.isMainOnly ? Images.placeHolderOneToOne :  Images.placeholder(context),
                        image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${ widget.bannerList![index].image}',
                        width: widget.bannerType == BannerType.primary ?  (widget.isMainOnly ? 1140 :   762) : (ResponsiveHelper.isDesktop(context) ?  380 : (size.width - 32)),
                        height: widget.bannerType == BannerType.primary ?  380 : (ResponsiveHelper.isDesktop(context) ?  380 : (size.width - 32)),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),

        if(widget.bannerType == BannerType.secondary)
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.bannerList!.map((bnr) {
                int index = widget.bannerList!.indexOf(bnr);
                return TabPageSelectorIndicator(
                  backgroundColor: index == currentIndex ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                  borderColor: index == currentIndex ? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
                  size: 10,
                );
              }).toList(),
            ),
          ),

        if(widget.bannerType == BannerType.primary) Positioned(
          right: 20, bottom: 100, top: 100,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('${currentIndex + 1}/${widget.bannerList!.length}', style: rubikRegular.copyWith(color: Theme.of(context).cardColor)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            RotatedBox(quarterTurns: 3, child: SizedBox(
              height: 5, width: 200,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusSizeDefault), topLeft: Radius.circular(Dimensions.radiusSizeDefault)),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: (((currentIndex + 1) * 100) / widget.bannerList!.length / 100),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.error.withOpacity(0.8)),
                  backgroundColor: Theme.of(context).cardColor,
                ),
              ),
            )),

          ]),
        ),
      ]),
    ) : const SizedBox();
  }
}
