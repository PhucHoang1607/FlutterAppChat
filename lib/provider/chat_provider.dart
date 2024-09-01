import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/last_message_model.dart';
import 'package:flutter_app_chat/model/message_model.dart';
import 'package:flutter_app_chat/model/message_reply_model.dart';
import 'package:flutter_app_chat/model/user_model.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setLoading(bool value) {
    _isLoading = true;
    notifyListeners();
  }

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //Send Text Message to fireStore
  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required String groupId,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    try {
      var messageId = const Uuid().v4();
      // 1. check if its a reply and add the replies message to message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      // 2. Update/set the messageModel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );

      // 3. check if its a group message and send to group else send to contact
      if (groupId.isNotEmpty) {
        //handle group message
      } else {
        //handle contact message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
        );

        //set message reply Model to null
        setMessageReplyModel(null);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> handleContactMessage(
      {required MessageModel messageModel,
      required String contactUID,
      required String contactName,
      required String contactImage,
      required Function onSucess,
      required Function(String p1) onError}) async {
    try {
      // 1. initialize last message for the sender
      final senderLastMessage = LastMessageModel(
        senderUID: messageModel.senderUID,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        message: messageModel.message,
        messageType: messageModel.messageType,
        timeSent: messageModel.timeSent,
        isSeen: false,
      );
      // 2. initialize last message for the contact
      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
      );

      //run transaction
      await _firestore.runTransaction((transaction) async {
        // 3. send message to sender firestore location
        transaction.set(
          _firestore
              .collection(Constants.users)
              .doc(messageModel.senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageModel.messageId),
          messageModel.toMap(),
        );
        // 4. send message to contact firestore location
        transaction.set(
          _firestore
              .collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(messageModel.senderUID)
              .collection(Constants.messages)
              .doc(messageModel.messageId),
          messageModel.toMap(),
        );
        // 5. send last message to sender firestore location
        transaction.set(
          _firestore
              .collection(Constants.users)
              .doc(messageModel.senderUID)
              .collection(Constants.chats)
              .doc(contactUID),
          senderLastMessage.toMap(),
        );
        // 6. send last message to contact firestore location
        transaction.set(
          _firestore
              .collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(messageModel.senderUID),
          contactLastMessage.toMap(),
        );
      });
      // 7. call onSuccess
    } on FirebaseException catch (e) {
      onError(e.message ?? e.toString());
    } catch (e) {
      onError(e.toString());
    }
  }
}
