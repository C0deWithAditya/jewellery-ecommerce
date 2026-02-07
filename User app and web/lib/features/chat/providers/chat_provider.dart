
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/features/chat/domain/models/chat_model.dart';
import 'package:hexacom_user/features/chat/domain/reposotories/chat_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../notification/domain/reposotories/notification_repo.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepo? chatRepo;
  final NotificationRepo? notificationRepo;
  ChatProvider({required this.chatRepo, required this.notificationRepo});

  List<bool>? _showDate;
  List<XFile>? _imageFiles;
  // XFile _imageFile;
  bool _isSendButtonActive = false;
  final bool _isSeen = false;
  final bool _isSend = true;
  bool _isMe = false;
  bool _isLoading= false;
  bool get isLoading => _isLoading;
  bool _currentRouteIsChat = false;

  List<bool>? get showDate => _showDate;
  List<XFile>? get imageFiles => _imageFiles;
  // XFile get imageFile => _imageFile;
  bool get isSendButtonActive => _isSendButtonActive;
  bool get isSeen => _isSeen;
  bool get isSend => _isSend;
  bool get isMe => _isMe;
  List<Messages>?  _messageList = [];
  List<Messages>? get messageList => _messageList;
  final List<Messages>  _adminManMessage = [];
  List<Messages> get adminManMessages => _adminManMessage;
  List <XFile>?_chatImage = [];
  List<XFile>? get chatImage => _chatImage;
  bool get currentRouteIsChat => _currentRouteIsChat;

  Future<void> getDeliveryManMessages (int orderId) async {
    ApiResponseModel apiResponse = await chatRepo!.getDeliveryManMessage(orderId,1);
    // _deliveryManMessages = [];
    if (apiResponse.response != null&& apiResponse.response!.data['messages']!= {} && apiResponse.response!.statusCode == 200) {
      _messageList?.addAll(ChatModel.fromJson(apiResponse.response!.data).messages!);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> getMessages (int offset, int? orderId, bool isFirst) async {
    ApiResponseModel apiResponse;
    if(isFirst) {
      _messageList = null;
    }
    
    if(orderId == null) {
      apiResponse = await chatRepo!.getAdminMessage(1);
    }else {
     apiResponse = await chatRepo!.getDeliveryManMessage(orderId, 1);
    }
    if (apiResponse.response != null&& apiResponse.response!.data['messages'] != {} && apiResponse.response!.statusCode == 200) {
      _messageList = [];
      _messageList?.addAll(ChatModel.fromJson(apiResponse.response!.data).messages!);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }


  void pickImage(bool isRemove) async {
    if(isRemove) {
      _imageFiles = [];
      _chatImage = [];
    }else {
      _imageFiles = await ImagePicker().pickMultiImage(imageQuality: 40);
      if (_imageFiles != null) {
        _chatImage = imageFiles;
        _isSendButtonActive = true;
      }
    }
    notifyListeners();
  }
  void removeImage(int index){
    chatImage!.removeAt(index);
    notifyListeners();
  }

  Future<http.StreamedResponse> sendMessageToDeliveryMan(String message, List<XFile> file, int orderId, BuildContext context, String token) async {
    _isLoading = true;
    // notifyListeners();
    http.StreamedResponse response = await chatRepo!.sendMessageToDeliveryMan(message, file, orderId, token);
    if (response.statusCode == 200) {
      // _imageFiles = [];
      // _chatImage = [];
      file =[];
      getDeliveryManMessages(orderId);
      _isLoading = false;
    }
    _imageFiles = [];
    _chatImage = [];
    _isSendButtonActive = false;
    notifyListeners();
    _isLoading = false;
    return response;
  }

  Future<http.StreamedResponse> sendMessage(String message, BuildContext context, String token, int? orderId) async {
    http.StreamedResponse response;
    _isLoading = true;
    // notifyListeners();
    if(orderId == null) {
      response = await chatRepo!.sendMessageToAdmin(message, _chatImage!, token);
    }else {
      response = await chatRepo!.sendMessageToDeliveryMan(message, _chatImage!, orderId, token);
    }
    if (response.statusCode == 200) {
      getMessages(1, orderId, false);
      _isLoading = false;
    }
    _imageFiles = [];
    _chatImage = [];
    _isSendButtonActive = false;
    notifyListeners();
    _isLoading = false;
    return response;
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    notifyListeners();
  }

  void setImageList(List<XFile> images) {
    _imageFiles = [];
    _imageFiles = images;
    _isSendButtonActive = true;
    notifyListeners();
  }

  void setIsMe(bool value) {
    _isMe = value;
  }

  void updateCurrentRouteStatus({bool status = false}){
    _currentRouteIsChat = status;
  }

}