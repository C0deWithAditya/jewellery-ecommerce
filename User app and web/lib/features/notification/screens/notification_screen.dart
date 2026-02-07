import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_image_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/helper/date_converter_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/notification/providers/notification_provider.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/no_data_screen.dart';
import 'package:hexacom_user/features/notification/widgets/notification_dialog_widget.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {


  @override
  void initState() {
    Provider.of<NotificationProvider>(context, listen: false).initNotificationList(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(90), child: WebAppBarWidget()) : CustomAppBarWidget(title: getTranslated('notification', context))) as PreferredSizeWidget?,
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          List<DateTime> dateTimeList = [];
          return notificationProvider.notificationList != null ? notificationProvider.notificationList!.isNotEmpty ? RefreshIndicator(
            color: Theme.of(context).secondaryHeaderColor,
            onRefresh: () async {
              await Provider.of<NotificationProvider>(context, listen: false).initNotificationList(context);
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: Center(child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: ListView.builder(
                      itemCount: notificationProvider.notificationList!.length,
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DateTime originalDateTime = DateConverterHelper.isoStringToLocalDate(notificationProvider.notificationList![index].createdAt!);
                        DateTime convertedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
                        bool addTitle = false;
                        if(!dateTimeList.contains(convertedDate)) {
                          addTitle = true;
                          dateTimeList.add(convertedDate);
                        }
                        return InkWell(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                          onTap: () {
                            showDialog(context: context, builder: (BuildContext context) {
                              return NotificationDialogWidget(notificationModel: notificationProvider.notificationList![index]);
                            });
                          },
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            addTitle ? Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              child: Text(DateConverterHelper.getRelativeDate(DateConverterHelper.isoStringToLocalDate(
                                notificationProvider.notificationList![index].createdAt!,
                              )) ?? DateConverterHelper.isoStringToLocalDateOnly(
                                notificationProvider.notificationList![index].createdAt!,
                              ), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            ) : const SizedBox(),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05), width: 1),
                              ),
                              child: Column(children: [

                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                  Expanded(child: Text(
                                    notificationProvider.notificationList?[index].title ?? '',
                                    style: rubikBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  const SizedBox(width: Dimensions.paddingSizeLarge),


                                        Text(
                                          DateConverterHelper.isoStringToLocalTimeOnly(notificationProvider.notificationList![index].createdAt!),
                                          style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),

                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                          notificationProvider.notificationList?[index].description ?? '',
                                          style: rubikRegular.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      CustomImageWidget(
                                        image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.notificationImageUrl}/${notificationProvider.notificationList![index].image}',
                                        height: 50,width: 50,fit: BoxFit.cover,
                                      ),

                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),


                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ))),

                const FooterWebWidget(footerType: FooterType.sliver),


              ],
            ),
          )
              : const NoDataScreen()
              : Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor));
        }
      ),
    );
  }
}
