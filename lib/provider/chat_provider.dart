import 'dart:ffi';
import 'dart:io';

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
    setLoading(true);
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
        //setLoading(false);
        setLoading(false);
        onSucess();
        setMessageReplyModel(null);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  //Send Image Message to firestore
  Future<void> sendFileMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required File file,
    required MessageEnum messageType,
    required String groupId,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    setLoading(true);

    try {
      var messageId = const Uuid().v4();

      // 1. Check if its a message reply and add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'You'
              : messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      // 2. upload file to firestore storage
      final ref =
          '${Constants.chatFiles}/${messageType.name}/${sender.uid}/$contactUID/$messageId';
      String fileUrl = await storeFileToStorage(file: file, reference: ref);
      // 3. update/set the messagemodel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: fileUrl,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );

      // 4. Check if its a group message and send to group else send to contact
      if (groupId.isNotEmpty) {
        //handle group message
      } else {
        // handle contact message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
        );
      }
      setMessageReplyModel(null);
      //setLoading(false);
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
      // 0. contact MessageModel
      final contactMessageModel =
          messageModel.copyWith(userId: messageModel.senderUID);
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
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      await // 3. send message to sender firestore location
          _firestore
              .collection(Constants.users)
              .doc(messageModel.senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageModel.messageId)
              .set(messageModel.toMap());

      await // 4. send message to contact firestore location
          _firestore
              .collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(messageModel.senderUID)
              .collection(Constants.messages)
              .doc(messageModel.messageId)
              .set(contactMessageModel.toMap());

      await // 5. send the last message to sender firestore location
          _firestore
              .collection(Constants.users)
              .doc(messageModel.senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .set(senderLastMessage.toMap());

      await // // 6. send the last message to contact firestore location
          _firestore
              .collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(messageModel.senderUID)
              .set(contactLastMessage.toMap());

      //====>> // run transaction
      // await _firestore.runTransaction((transaction) async {
      //   // 3. send message to sender firestore location
      //   transaction.set(
      //     _firestore
      //         .collection(Constants.users)
      //         .doc(messageModel.senderUID)
      //         .collection(Constants.chats)
      //         .doc(contactUID)
      //         .collection(Constants.messages)
      //         .doc(messageModel.messageId),
      //     messageModel.toMap(),
      //   );
      //   // 4. send message to contact firestore location
      //   transaction.set(
      //     _firestore
      //         .collection(Constants.users)
      //         .doc(contactUID)
      //         .collection(Constants.chats)
      //         .doc(messageModel.senderUID)
      //         .collection(Constants.messages)
      //         .doc(messageModel.messageId),
      //     contactMessageModel.toMap(),
      //   );
      //   // 5. send the last message to sender firestore location
      //   transaction.set(
      //     _firestore
      //         .collection(Constants.users)
      //         .doc(messageModel.senderUID)
      //         .collection(Constants.chats)
      //         .doc(contactUID),
      //     senderLastMessage.toMap(),
      //   );
      //   // 6. send the last message to contact firestore location
      //   transaction.set(
      //     _firestore
      //         .collection(Constants.users)
      //         .doc(contactUID)
      //         .collection(Constants.chats)
      //         .doc(messageModel.senderUID),
      //     contactLastMessage.toMap(),
      //   );
      // });
      // 7. call onSuccess
      //set loading to false
      setLoading(false);
      onSucess();
    } on FirebaseException catch (e) {
      setLoading(false);
      onError(e.message ?? e.toString());
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  //get the chat list screen
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LastMessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  //set a message as seen
  Future<void> setMessageAsSeen(
      {required String userId,
      required String contactUID,
      required String messageId,
      required String groupId}) async {
    try {
      // 1.Check if its a group message
      if (groupId.isNotEmpty) {
        //handle group message
      } else {
        //handle contact message
        //2. update the current message as seen
        await _firestore
            .collection(Constants.users)
            .doc(userId)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId)
            .update({Constants.isSeen: true});

        // 3. update the contact message as seen
        await _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(userId)
            .collection(Constants.messages)
            .doc(messageId)
            .update({Constants.isSeen: true});

        //4. update the last message as seen for current user
        await _firestore
            .collection(Constants.users)
            .doc(userId)
            .collection(Constants.chats)
            .doc(contactUID)
            .update({Constants.isSeen: true});

        // 5. Update the last messages as seen for contact
        await _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(userId)
            .update({Constants.isSeen: true});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //stream chat collection
  Stream<List<MessageModel>> getMessageStream({
    required String userId,
    required String contactUID,
    required String isGroup,
  }) {
    // 1. check if its a group message
    if (isGroup.isNotEmpty) {
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          //.orderBy(Constants.timeSent, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    } else {
      return _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          //.orderBy(Constants.timeSent, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    }
  }

  //store file to storage and return file url
  Future<String> storeFileToStorage(
      {required File file, required String reference}) async {
    UploadTask uploadTask =
        _firebaseStorage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }
}
