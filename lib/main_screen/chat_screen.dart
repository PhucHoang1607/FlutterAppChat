import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/message_model.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/provider/chat_provider.dart';
import 'package:flutter_app_chat/widgets/bottom_chat_field.dart';
import 'package:flutter_app_chat/widgets/chat_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
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
              child: StreamBuilder<List<MessageModel>>(
                stream: context.read<ChatProvider>().getMessageStream(
                    userId: uid, contactUID: contactUID, isGroup: groupId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('SOmething went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Start the conversation',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    final messageList = snapshot.data!;
                    return GroupedListView<dynamic, DateTime>(
                      elements: messageList,
                      groupBy: (element) {
                        return DateTime(
                          element.timeSent!.year,
                          element.timeSent!.month,
                          element.timeSent!.day,
                        );
                      },
                      groupSeparatorBuilder: (dynamic groupByValue) =>
                          Text(groupByValue),
                      itemBuilder: (context, dynamic element) =>
                          Text(element['name']),
                      itemComparator: (item1, item2) =>
                          item1['name'].compareTo(item2['name']), // optional
                      useStickyGroupSeparators: true, // optional
                      floatingHeader: true, // optional
                      order: GroupedListOrder.ASC, // optional
                      footer: Text("Widget at the bottom of list"), // optional
                    );
                  }
                  return const SizedBox.shrink();
                },
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
