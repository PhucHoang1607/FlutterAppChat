import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/model/message_model.dart';
import 'package:flutter_app_chat/model/message_reply_model.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/provider/chat_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:flutter_app_chat/widgets/contact_message_widget.dart';
import 'package:flutter_app_chat/widgets/my_message_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key, required this.contactUID, required this.groupId});

  final String contactUID;
  final String groupId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //current user uid
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    //get the contactID from the argument

    return StreamBuilder<List<MessageModel>>(
      stream: context.read<ChatProvider>().getMessageStream(
          userId: uid, contactUID: widget.contactUID, isGroup: widget.groupId),
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

        //automatic scroll to the bottom of the liston new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut);
        });
        if (snapshot.hasData) {
          final messageList = snapshot.data!;
          return GroupedListView<dynamic, DateTime>(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            reverse: true,
            controller: _scrollController,
            elements: messageList,
            groupBy: (element) {
              return DateTime(
                element.timeSent!.year,
                element.timeSent!.month,
                element.timeSent!.day,
              );
            },
            groupHeaderBuilder: (dynamic groupedByValue) {
              return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: buildDateTime(groupedByValue));
            },
            itemBuilder: (context, dynamic element) {
              //set messages as seen
              if (!element.isSeen && element.senderUID != uid) {
                print('running');
                context.read<ChatProvider>().setMessageAsSeen(
                      userId: uid,
                      contactUID: widget.contactUID,
                      messageId: element.messageId,
                      groupId: widget.groupId,
                    );
              }

              final dateTime =
                  formatDate(element.timeSent, [hh, ':', nn, ' ', am]);
              //Check if we sent the last message
              final isMe = element.senderUID == uid;
              return isMe
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: MyMessageWidget(
                        message: element,
                        onLeftSwipe: () {
                          //set there message
                          final messageReply = MessageReplyModel(
                            message: element.message,
                            senderUID: element.senderUID,
                            senderName: element.senderName,
                            senderImage: element.senderImage,
                            messageType: element.messageType,
                            isMe: isMe,
                          );
                          context
                              .read<ChatProvider>()
                              .setMessageReplyModel(messageReply);
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: ContactMessageWidget(
                        message: element,
                        onRightSwipe: () {
                          // set the message
                          final messageReply = MessageReplyModel(
                            message: element.message,
                            senderUID: element.senderUID,
                            senderName: element.senderName,
                            senderImage: element.senderImage,
                            messageType: element.messageType,
                            isMe: isMe,
                          );

                          context
                              .read<ChatProvider>()
                              .setMessageReplyModel(messageReply);
                        },
                      ),
                    );
            },
            groupComparator: (value1, value2) {
              return value2.compareTo(value1);
            },
            itemComparator: (item1, item2) {
              var firstItem = item1.timeSent;

              var secondItem = item2.timeSent;

              return secondItem!.compareTo(firstItem!);
            }, // optional

            useStickyGroupSeparators: true, // optional
            floatingHeader: true, // optional
            order: GroupedListOrder.ASC, // optional
            // optional
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
