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
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
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
                            color: Colors.grey[400],
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
                                      color: Colors.black,
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
                                    color: Colors.black,
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
                        color: Colors.black,
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
                      style: const TextStyle(
                        color: Colors.black,
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
