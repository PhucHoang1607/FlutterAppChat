import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_chat/model/message_model.dart';
import 'package:flutter_app_chat/model/message_reply_model.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/provider/chat_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:flutter_app_chat/widgets/contact_message_widget.dart';
import 'package:flutter_app_chat/widgets/my_message_widget.dart';
import 'package:flutter_app_chat/widgets/reactions_dialog.dart';
import 'package:flutter_app_chat/widgets/stacked_reactions.dart';
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

  void onContextMenuClicked(
      {required String item, required MessageModel message}) {
    switch (item) {
      case 'Reply':
        //set message reply to true
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );
        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;

      case 'Copy':
        //copy to clipboard
        Clipboard.setData(ClipboardData(text: message.message));
        showSnackBar(context, 'Message cpied to clipboard');
        break;

      case 'Delete':
        //TODO selete message
        // context.read<ChatProvider>().deleteMessage(
        //     userId: uid,
        //     contactUID: widget.contactUID,
        //     messageId: message.messageId,
        //     groupId: widget.groupId);
        print('Delete');
        break;
    }
  }

  showReactionDialog({required MessageModel message, required bool isMe}) {
    showDialog(
      context: context,
      builder: (context) => ReactionsDialog(
        isMyMessage: isMe,
        message: message,
        onReactionsTap: (reaction) {
          //Navigator.pop(context);
          print('show $reaction');

          if (reaction == '➕') {
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pop(context);
              showEmojiContainer(messageId: message.messageId);
            });
          } else {
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pop(context);
              //add reaction to message
              sendReactionToMessage(
                  reaction: reaction, messageId: message.messageId);
            });
          }
        },
        onContextMenuTap: (item) {
          Navigator.pop(context);
          onContextMenuClicked(item: item, message: message);
        },
      ),
    );
  }

  void sendReactionToMessage(
      {required String reaction, required String messageId}) {
    //get the senderUID
    final senderUID = context.read<AuthenticationProvider>().userModel!.uid;

    context.read<ChatProvider>().sendReactionToMessages(
          senderUID: senderUID,
          contactUID: widget.contactUID,
          messageId: messageId,
          reaction: reaction,
          groupId: widget.groupId.isNotEmpty,
        );
  }

  void showEmojiContainer({required String messageId}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            print(emoji);
            Navigator.pop(context);
            // add emoji to message
            sendReactionToMessage(reaction: emoji.emoji, messageId: messageId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //current user uid
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    //get the contactID from the argument

    return GestureDetector(
      child: StreamBuilder<List<MessageModel>>(
        stream: context.read<ChatProvider>().getMessageStream(
            userId: uid,
            contactUID: widget.contactUID,
            isGroup: widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
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
                final padding1 = element.reactions.isEmpty ? 0.0 : 20.0;
                final padding2 = element.reactions.isEmpty ? 0.0 : 25.0;

                //set messages as seen
                if (!element.isSeen && element.senderUID != uid) {
                  //print('running');
                  context.read<ChatProvider>().setMessageAsSeen(
                        userId: uid,
                        contactUID: widget.contactUID,
                        messageId: element.messageId,
                        groupId: widget.groupId,
                      );
                }

                // final dateTime =
                //     formatDate(element.timeSent, [hh, ':', nn, ' ', am]);

                //Check if we sent the last message
                final isMe = element.senderUID == uid;
                return isMe
                    ? Stack(
                        children: [
                          InkWell(
                            onLongPress: () {
                              showReactionDialog(message: element, isMe: isMe);
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: 8.0, bottom: padding1),
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
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 90,
                            child: StackedReactionsWidget(
                              message: element,
                              size: 20,
                              onTap: () {
                                //show bottom sheet with list of people
                              },
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          InkWell(
                            onLongPress: () {
                              showReactionDialog(message: element, isMe: isMe);
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: 8.0, bottom: padding2),
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
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 110,
                            child: StackedReactionsWidget(
                              message: element,
                              size: 20,
                              onTap: () {},
                            ),
                          ),
                        ],
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
      ),
    );
  }
}
