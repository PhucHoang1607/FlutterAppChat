import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/widgets/bottom_chat_field.dart';
import 'package:flutter_app_chat/widgets/chat_appbar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    //get argument from the previous  screen
    final argument = ModalRoute.of(context)!.settings.arguments as Map;
    //get the contactID from the argument
    final contactId = argument[Constants.contactId];

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
        title: ChatAppBar(contactId: contactId),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('message $index'),
                  );
                },
              ),
            ),
          ),
          BottomChatField(
            contactId: contactId,
            contactName: contactName,
            contactImage: contactImage,
            groupId: groupId,
          ),
        ],
      ),
    );
  }
}
