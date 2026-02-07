import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/onboarding/providers/onboarding_provider.dart';
import 'package:hexacom_user/utill/color_resources.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<OnBoardingProvider>(context, listen: false).initBoardingList(context);

    return CustomPopScopeWidget(
      child: Scaffold(
        body: Consumer<OnBoardingProvider>(
          builder: (context, onBoardingList, child) => onBoardingList.onBoardingList.isNotEmpty ? SafeArea(
            child: ListView(
              children: [

                onBoardingList.selectedIndex != onBoardingList.onBoardingList.length-1 ? Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                      onPressed: () {
                        onBoardingList.toggleShowOnBoardingStatus();
                        RouteHelper.getWelcomeRoute(context, action: RouteAction.pushReplacement);
                      },
                      child: Text(
                        getTranslated('skip', context),
                        style: rubikRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                      )),
                ) : const SizedBox(),

                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    itemCount: onBoardingList.onBoardingList.length,
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(30),
                        child: Image.asset(onBoardingList.onBoardingList[index].imageUrl),
                      );
                    },
                    onPageChanged: (index) {
                      onBoardingList.changeSelectIndex(index);
                    },
                  ),
                ),

                Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _getIndexList(onBoardingList.onBoardingList.length).map((i) => Container(
                        width: i == Provider.of<OnBoardingProvider>(context).selectedIndex ? 16 : 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: i == Provider.of<OnBoardingProvider>(context).selectedIndex ? Theme.of(context).primaryColor : ColorResources.getGrayColor(context),
                          borderRadius: i == Provider.of<OnBoardingProvider>(context).selectedIndex ? BorderRadius.circular(50) : BorderRadius.circular(25),
                        ),
                      )).toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60, right: 60, top: 50, bottom: 22),
                      child: Text(
                        onBoardingList.selectedIndex == 0
                            ? onBoardingList.onBoardingList[0].title
                            : onBoardingList.selectedIndex == 1
                                ? onBoardingList.onBoardingList[1].title
                                : onBoardingList.onBoardingList[2].title,
                        style: rubikRegular.copyWith(fontSize: 24.0, color: Theme.of(context).textTheme.bodyLarge!.color),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Text(
                        onBoardingList.selectedIndex == 0
                            ? onBoardingList.onBoardingList[0].description
                            : onBoardingList.selectedIndex == 1
                                ? onBoardingList.onBoardingList[1].description
                                : onBoardingList.onBoardingList[2].description,
                        style: rubikMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: ColorResources.getGrayColor(context),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(onBoardingList.selectedIndex == 2 ? 0 : 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          onBoardingList.selectedIndex == 0 || onBoardingList.selectedIndex == 2
                              ? const SizedBox.shrink()
                              : TextButton(
                                  onPressed: () {
                                    _pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.ease);
                                  },
                                  child: Text(
                                    getTranslated('previous', context),
                                    style: rubikRegular.copyWith(color: ColorResources.getGrayColor(context)),
                                  )),
                          onBoardingList.selectedIndex == 2
                              ? const SizedBox.shrink()
                              : TextButton(
                                  onPressed: () {
                                    _pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.ease);
                                  },
                                  child: Text(
                                    getTranslated('next', context),
                                    style: rubikRegular.copyWith(color: ColorResources.getGrayColor(context)),
                                  )),
                        ],
                      ),
                    ),
                    onBoardingList.selectedIndex == 2
                        ? Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                            child: CustomButtonWidget(
                              btnTxt: getTranslated('lets_start', context),
                              onTap: () {
                                RouteHelper.getWelcomeRoute(context, action: RouteAction.pushReplacement);
                              },
                            ))
                        : const SizedBox.shrink()
                  ],
                ),
              ],
            ),
          ) : const SizedBox(),
        ),
      ),
    );
  }

  List<int> _getIndexList(int length) {
    List<int> list = [];

    for(int i = 0; i < length; i++) {
      list.add(i);
    }

    return list;
  }
}


