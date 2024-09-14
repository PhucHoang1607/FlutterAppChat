import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/message_model.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';

class ReactionsDialog extends StatefulWidget {
  const ReactionsDialog({
    super.key,
    required this.isMyMessage,
    required this.message,
    required this.onReactionsTap,
    required this.onContextMenuTap,
  });

  final bool isMyMessage;
  final MessageModel message;
  final Function(String) onReactionsTap;
  final Function(String) onContextMenuTap;

  @override
  State<ReactionsDialog> createState() => _ReactionsDialogState();
}

class _ReactionsDialogState extends State<ReactionsDialog> {
  bool reactionClicked = false;
  int? clickedReactionIndex;
  int? clickedContextMenuIndex;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade500,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final reaction in reactions)
                        InkWell(
                            onTap: () {
                              widget.onReactionsTap(reaction);
                              setState(() {
                                clickedReactionIndex =
                                    reactions.indexOf(reaction);
                              });
                              //set back to false after miliseconds
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                //     () {
                                //   setState(() {
                                //     reactionClicked = false;
                                //   });
                                // }
                              );
                            },
                            child: Pulse(
                              infinite: false,
                              duration: const Duration(milliseconds: 500),
                              animate: reactionClicked &&
                                  clickedReactionIndex ==
                                      reactions.indexOf(reaction),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  reaction,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ))
                    ],
                  ),
                ),
              ),
            ),

            //where we show our text
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: widget.isMyMessage
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade600,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.message.messageType == MessageEnum.text
                        ? Text(
                            widget.message.message,
                            style: const TextStyle(color: Colors.white),
                          )
                        : widget.message.messageType == MessageEnum.image
                            ? const Column(
                                children: [
                                  Text('Image'),
                                  Icon(
                                    Icons.image,
                                  ),
                                ],
                              )
                            : widget.message.messageType == MessageEnum.video
                                ? const Column(
                                    children: [
                                      Text('Video'),
                                      Icon(Icons.video_library),
                                    ],
                                  )
                                : const Column(
                                    children: [
                                      Text('Audio'),
                                      Icon(Icons.audio_file),
                                    ],
                                  ),
                  ),
                ),
              ),
            ),

            Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: widget.isMyMessage
                            ? Theme.of(context).colorScheme.inversePrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          )
                        ]),
                    child: Column(
                      children: [
                        for (final menu in contextMenu)
                          InkWell(
                            onTap: () {
                              widget.onContextMenuTap(menu);
                              setState(() {
                                clickedContextMenuIndex =
                                    contextMenu.indexOf(menu);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    menu,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Pulse(
                                    infinite: false,
                                    duration: const Duration(milliseconds: 500),
                                    animate: clickedContextMenuIndex ==
                                        contextMenu.indexOf(menu),
                                    child: Icon(
                                      menu == 'Reply'
                                          ? Icons.reply
                                          : menu == 'Copy'
                                              ? Icons.copy
                                              : Icons.delete,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
