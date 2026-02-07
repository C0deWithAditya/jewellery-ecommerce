import 'package:hexacom_user/helper/product_helper.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/home/providers/banner_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({Key? key}) : super(key: key);

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {

  final ScrollController _scrollController = ScrollController();

  double _progressValue = 0.2;

  double _currentSliderValue = 0;

  double _listLength = 0;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
  }

  void _updateProgress() {
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double progress = currentScroll / maxScrollExtent;
    setState(() {
      _progressValue = progress;

      _currentSliderValue = _progressValue * _listLength;
      if(_currentSliderValue < 1){
        _currentSliderValue = 0;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.sizeOf(context).width - (Dimensions.paddingSizeDefault * 2);

    return Column(children: [

      Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: TitleWidget(title: getTranslated('banner', context)),
      ),

      Stack(children: [

        SizedBox(height: (size / 2), child: Consumer<BannerProvider>(
          builder: (context, banner, child) {
            if(banner.bannerList != null) {
              _listLength = banner.bannerList!.length.toDouble();
              if(_listLength == 1) {
                _progressValue = 1;
              }
            }

            return banner.bannerList != null ? banner.bannerList!.isNotEmpty ? ListView.builder(
              controller: _scrollController,
              itemCount: banner.bannerList!.length,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap:  () => ProductHelper.onTapBannerForRoute(banner.bannerList![index], context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      // margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).shadowColor,
                              spreadRadius: 1, blurRadius: 5),
                        ],
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomImageWidget(
                            placeholder: Images.placeholder(context),
                            image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${banner.bannerList![index].image}',
                            width: size,
                            height: (size / (banner.secondaryBannerList != null && banner.secondaryBannerList!.isNotEmpty ? 2 : 3)),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ) : Center(child: Text(getTranslated('no_banner_available', context))) : const BannerShimmer();
          },
        )),


        Consumer<BannerProvider>(
            builder: (context, banner, child) {
            return Positioned(
              right: 35, bottom: 20, top: 20,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text('${_currentSliderValue.toInt() + (_currentSliderValue.toInt() >= _listLength.toInt() ? 0 : 1)}/${_listLength.toInt()}', style: rubikRegular.copyWith(color: Theme.of(context).cardColor)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    height: 5, width: 120,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusSizeDefault), topLeft: Radius.circular(Dimensions.radiusSizeDefault)),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: _progressValue,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.error.withOpacity(0.8)),
                        backgroundColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                ),

              ]),
            );
          }
        ),

      ]),

    ]);
  }
}

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: Provider.of<BannerProvider>(context).bannerList == null,
      child: Container(
        width: ResponsiveHelper.isDesktop(context) ? 320 : MediaQuery.sizeOf(context).width - 32,
        height: 160,
        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 1, blurRadius: 5)],
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

