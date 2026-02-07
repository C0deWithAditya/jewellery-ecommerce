import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProductDetailsShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isWeb;
  const ProductDetailsShimmerWidget({Key? key, required this.isEnabled, this.isWeb = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size  = MediaQuery.of(context).size;
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: isEnabled,
      child: isWeb
          ? SingleChildScrollView(
            child: Column(
        children: [
            SizedBox(
              height: size.height*0.7,
              width: Dimensions.webScreenWidth,
              child: Row(
                children: [
                  Expanded(child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        Container(width: double.infinity,height: size.height*0.45,color: Theme.of(context).shadowColor,),
                        const SizedBox(height: 50),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(right: 10),
                              itemBuilder: (context, index) {
                            return Container(margin: const EdgeInsets.only(right: 10),width: 100,height: 100,color: Theme.of(context).shadowColor);
                          }),
                        )

                      ],
                    ),
                  )),
                  const SizedBox(width: 20,),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SizedBox(height: 100),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Container(
                        height: 20,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ],),
                      const SizedBox(height: 50),
                    Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                      const SizedBox(height: 50),
                    Row(children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ],)
                  ],)),

                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Container(
                    height: 15,
                    width: 200,
                    color: Theme.of(context).shadowColor
                ),
                const SizedBox(width: 20,),
                Container(
                    height: 15,
                    width: 200,
                    color: Theme.of(context).shadowColor
                ),
              ],),
            ),
            const SizedBox(height: 20),
            SizedBox(
                width: Dimensions.webScreenWidth,
              child: Container(
                  height: 100,
                  width: double.maxFinite,
                  color: Theme.of(context).shadowColor),
            ),

        ],
      ),
          )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), physics: const BouncingScrollPhysics(),
        child: Center(
          child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                  height: MediaQuery.of(context).size.width * 0.7,
                    width: MediaQuery.of(context).size.width * 0.95,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width * 0.65,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 20,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 20,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],),
                  const Divider(height: 20, thickness: 2),
                  const SizedBox(height: Dimensions.paddingSizeLarge) ,

                  // Quantity
                  Row(children: [
                    Container(
                      height: Dimensions.fontSizeLarge,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 30,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Container(
                    height: Dimensions.fontSizeExtraLarge,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // Tab Bar
                  Row(children: [
                    Expanded(child: Container(
                      height: 30,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),),
                    const SizedBox(width: 20),
                    Expanded(child: Container(
                      height: 30,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),),
                  ]),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.98,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),


                ]),
          ),
        ),
      ),
    );
  }
}
