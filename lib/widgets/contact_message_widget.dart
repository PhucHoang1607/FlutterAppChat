import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/message_model.dart';
import 'package:flutter_app_chat/widgets/display_message_type.dart';
import 'package:swipe_to/swipe_to.dart';

class ContactMessageWidget extends StatelessWidget {
  const ContactMessageWidget({
    super.key,
    required this.message,
    required this.onRightSwipe,
  });

  final MessageModel message;
  final Function() onRightSwipe;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ', am]);
    final isReplying = message.repliedTo.isNotEmpty;
    final senderName = message.repliedTo == "You" ? message.senderName : "You";
    //CHECK IF IS DARK MODE
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Card(
            elevation: 5,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            color: Theme.of(context).cardColor,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 30,
                    top: 5,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isReplying) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: message.messageType == MessageEnum.text
                                ? const EdgeInsets.fromLTRB(10, 5, 20, 20)
                                : const EdgeInsets.fromLTRB(5, 5, 5, 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  senderName,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold),
                                ),
                                DisplayMessageType(
                                  message: message.repliedMessage,
                                  type: message.repliedMessageType,
                                  isReply: true,
                                  color: Colors.black,
                                  maxLines: 1,
                                  overFlow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  message.repliedMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    //fontSize: 10,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                      DisplayMessageType(
                        message: message.message,
                        type: message.messageType,
                        isReply: false,
                        color: isDarkMode ? Colors.white : Colors.black,
                        maxLines: null,
                        overFlow: null,
                      ),
                      // Text(
                      //   message.message,
                      //   style: const TextStyle(
                      //     color: Colors.black,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Positioned(
                    bottom: 4,
                    right: 10,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 10,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
