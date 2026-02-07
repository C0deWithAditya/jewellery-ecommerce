import 'package:flutter/material.dart';
import 'package:hexacom_user/common/widgets/custom_asset_image_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/features/address/providers/location_provider.dart';
import 'package:hexacom_user/features/address/screens/select_location_screen.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

class WithoutMapWidget extends StatelessWidget {
  const WithoutMapWidget({super.key});


  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    final LocationProvider locationProvider = context.read<LocationProvider>();


    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        child:  Stack(clipBehavior: Clip.none, children: [

          CustomAssetImageWidget(
            Images.noMapBackground,
            fit: BoxFit.cover,
            height: ResponsiveHelper.isDesktop(context) ? size.height * 0.5 : size.height * 0.2,
            width: MediaQuery.of(context).size.width,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),

          Positioned.fill(child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Text(getTranslated('add_location_from_map_your_precise_location', context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: rubikRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeLarge
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Row(children: [

                Expanded(child: Container()),

                Expanded(child: CustomButtonWidget(
                  isLoading: locationProvider.isLoading,
                  btnTxt: getTranslated('go_to_map', context),
                  onTap: ()async{

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>  const SelectLocationScreen(),
                    ));

                  },
                  backgroundColor: Theme.of(context).cardColor,
                  style: rubikBold.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ),

                Expanded(child: Container()),
              ]),


            ]),
          ),),

        ],),
      ),
    );
  }
}