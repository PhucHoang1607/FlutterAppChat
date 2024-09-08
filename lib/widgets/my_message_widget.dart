import 'package:date_format/date_format.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/message_model.dart';
import 'package:flutter_app_chat/widgets/display_message_type.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget(
      {super.key, required this.message, required this.onLeftSwipe});

  final MessageModel message;
  final Function() onLeftSwipe;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ', am]);
    final isReplying = message.repliedTo.isNotEmpty;
    return SwipeTo(
      onLeftSwipe: (details) {
        onLeftSwipe();
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.3,
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: message.messageType == MessageEnum.text
                      ? const EdgeInsets.fromLTRB(10, 5, 20, 20)
                      : const EdgeInsets.fromLTRB(5, 5, 5, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isReplying) ...[
                        Container(
                          //padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .canvasColor
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  message.repliedTo,
                                  style: const TextStyle(
                                    color: Colors.purpleAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                DisplayMessageType(
                                    message: message.repliedMessage,
                                    type: message.messageType,
                                    color: Colors.white,
                                    maxLines: 1,
                                    overFlow: TextOverflow.ellipsis),
                                // Text(
                                //   message.repliedMessage,
                                //   maxLines: 1,
                                //   overflow: TextOverflow.ellipsis,
                                //   style: const TextStyle(color: Colors.white),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      DisplayMessageType(
                        message: message.message,
                        type: message.messageType,
                        color: Colors.white,
                        maxLines: null,
                        overFlow: null,
                      ),
                      // Text(
                      //   message.message,
                      //   style: const TextStyle(color: Colors.white),
                      // ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        time,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        message.isSeen ? Icons.done_all : Icons.done,
                        color: message.isSeen ? Colors.blue : Colors.white,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
