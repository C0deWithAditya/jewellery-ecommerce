import 'dart:io';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/features/chat/widgets/message_bubble_widget.dart';
import 'package:hexacom_user/features/chat/widgets/message_bubble_shimmer_widget.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/features/auth/providers/auth_provider.dart';
import 'package:hexacom_user/features/chat/providers/chat_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/main.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/images.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final int? orderId;
  final String? userName;
  final String? profileImage;
  const ChatScreen({super.key, this.orderId, this.userName, this.profileImage});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputMessageController = TextEditingController();
  late bool _isLoggedIn;
  bool _isFirst = true;

  @override
  void initState() {
    super.initState();

    Provider.of<ChatProvider>(Get.context!, listen: false).updateCurrentRouteStatus(status: true);
    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    if(_isLoggedIn){

      Provider.of<ProfileProvider>(context, listen: false).getUserInfo();

      if(_isFirst) {
        Provider.of<ChatProvider>(context, listen: false).getMessages(1, widget.orderId, true);
      }else {
        Provider.of<ChatProvider>(context, listen: false).getMessages(1, widget.orderId, false);
        _isFirst = false;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    Provider.of<ChatProvider>(Get.context!, listen: false).updateCurrentRouteStatus(status: false);
  }

  @override
  Widget build(BuildContext context) {

    final bool isAdmin = widget.orderId == null;
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const CustomAppBarWidget() : AppBar(
          title: Text(
            isAdmin ? '${splashProvider.configModel?.ecommerceName}' :
            '${widget.userName}',
            style: rubikMedium.copyWith(color: Theme.of(context).secondaryHeaderColor),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            onPressed: () {
              if(Navigator.canPop(context)){
                Navigator.pop(context);
              }else{
                RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
              }
            },
          ),

        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(width: 40,height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 2,color: Theme.of(context).cardColor),
                  color: Theme.of(context).cardColor),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FadeInImage.assetNetwork(
                  fit: BoxFit.cover,
                  placeholder: isAdmin ? Images.logo : Images.profile,
                  image: isAdmin ? '' : '${splashProvider.baseUrls!.deliveryManImageUrl}/${widget.profileImage}',
                  imageErrorBuilder: (c,t,o) => Image.asset(isAdmin ? Images.logo : Images.profile),
                ),
              ),
            ),
          )
        ],
      ) ,

      body: _isLoggedIn? SafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: ResponsiveHelper.isDesktop(context) ?1170:MediaQuery.of(context).size.width,
                  height: size.height * 0.8,
                  child: Column(
                    children: [
            
                      Consumer<ChatProvider>(
                          builder: (context, chatProvider,child) {
                            return chatProvider.messageList == null ?  Expanded(child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: 24,
                              itemBuilder: (context, index)=> MessageBubbleShimmerWidget(isMe: index.isOdd),
                            )) : Expanded(
                              child: ListView.builder(
                                  reverse: true,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: chatProvider.messageList!.length,
                                  itemBuilder: (context, index){
                                    return MessageBubbleWidget(messages: chatProvider.messageList![index], isAdmin: isAdmin);
                                  }),
                            );
                          }
                      ),
            
                      Container(

                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).primaryColor
                          ),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                        ),
                        child: Column(
                          children: [
                            Consumer<ChatProvider>(
                                builder: (context, chatProvider,_) {
                                  return chatProvider.chatImage!.isNotEmpty?
                                  SizedBox(height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: chatProvider.chatImage!.length,
                                      itemBuilder: (BuildContext context, index){
                                        return  chatProvider.chatImage!.isNotEmpty?
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Stack(
                                            children: [
                                              Container(width: 100, height: 100,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                                  child: ResponsiveHelper.isWeb()? Image.network(chatProvider.chatImage![index].path, width: 100, height: 100,
                                                    fit: BoxFit.cover,
                                                  ):Image.file(File(chatProvider.chatImage![index].path), width: 100, height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ) ,
                                              ),
                                              Positioned(
                                                top:0,right:0,
                                                child: InkWell(
                                                  onTap :() => chatProvider.removeImage(index),
                                                  child: Container(
                                                      decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                                                      ),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(4.0),
                                                        child: Icon(Icons.clear,color: Colors.red,size: 15,),
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ):const SizedBox();
            
                                      },),
                                  ):const SizedBox();
                                }
                            ),
                            Row(children: [
                              InkWell(
                                onTap: () async {
                                  Provider.of<ChatProvider>(context, listen: false).pickImage(false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: Image.asset(Images.image, width: 25, height: 25, color: Theme.of(context).hintColor),
                                ),
                              ),
                              SizedBox(
                                height: 25,
                                child: VerticalDivider(width: 0, thickness: 1, color: Theme.of(context).hintColor),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeDefault),
                              Expanded(
                                child: TextField(
                                  inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                                  controller: _inputMessageController,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: rubikRegular,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: getTranslated('type_here', context),
                                    hintStyle: rubikRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                                  ),
                                  onSubmitted: (String newText) {
                                    if(newText.trim().isNotEmpty && !Provider.of<ChatProvider>(context, listen: false).isSendButtonActive) {
                                      Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
                                    }else if(newText.isEmpty && Provider.of<ChatProvider>(context, listen: false).isSendButtonActive) {
                                      Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
                                    }
                                  },
                                  onChanged: (String newText) {
                                    if(newText.trim().isNotEmpty && !Provider.of<ChatProvider>(context, listen: false).isSendButtonActive) {
                                      Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
                                    }else if(newText.isEmpty && Provider.of<ChatProvider>(context, listen: false).isSendButtonActive) {
                                      Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
                                    }
                                  },
            
                                ),
                              ),
            
            
            
            
                              InkWell(
                                onTap: () async {
                                  if(Provider.of<ChatProvider>(context, listen: false).isSendButtonActive){
                                      Provider.of<ChatProvider>(context, listen: false).sendMessage(_inputMessageController.text, context, Provider.of<AuthProvider>(context, listen: false).getUserToken(), widget.orderId);
                                      _inputMessageController.clear();
                                    Provider.of<ChatProvider>(context, listen: false).toggleSendButtonActivity();
            
                                  }else{
                                    showCustomSnackBar(getTranslated('write_somethings', context), context);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: Provider.of<ChatProvider>(context, listen: false).isLoading ? const SizedBox(
                                    width: 25, height: 25,
                                    child: CircularProgressIndicator(),
                                  ) : Image.asset(Images.send, width: 25, height: 25,
                                    color: Provider.of<ChatProvider>(context).isSendButtonActive ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                  ),
                                ),
                              ),
            
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

            
            
                if(ResponsiveHelper.isDesktop(context))...[
                  Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      const FooterWebWidget(footerType: FooterType.nonSliver),
                    ],
                  ),
                ]
            
            
              ],
            ),
          ),
        ),
      ): const NotLoggedInScreen(),
    );
  }
}
