import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';

import 'package:flutter_app_chat/provider/authentication_provider.dart';

import 'package:flutter_app_chat/widgets/bottom_chat_field.dart';
import 'package:flutter_app_chat/widgets/chat_appbar.dart';
import 'package:flutter_app_chat/widgets/chat_list.dart';

import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    //current user uid
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    //get argument from the previous  screen
    final argument = ModalRoute.of(context)!.settings.arguments as Map;
    //get the contactID from the argument
    final contactUID = argument[Constants.contactUID];

    //get the contactName from the argument
    final contactName = argument[Constants.contactName];

    //get the contactImage from the argument
    final contactImage = argument[Constants.contactImage];

    //get the groupId from the argument
    final groupId = argument[Constants.groupId];

    //check if the groupId is Empty - then its a chat with a friend else its a froiup chat
    final isGroupChat = groupId.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactUID: contactUID),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChatList(
                contactUID: contactUID,
                groupId: groupId,
              ),
            ),
          ),
          BottomChatField(
            contactUID: contactUID,
            contactName: contactName,
            contactImage: contactImage,
            groupId: groupId,
          ),
        ],
      ),
    );
  }
}
