import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/widgets/audio_player_widget.dart';
import 'package:flutter_app_chat/widgets/video_player_widget.dart';

//This widget use what to show the Type of message
class DisplayMessageType extends StatelessWidget {
  const DisplayMessageType(
      {super.key,
      required this.message,
      required this.type,
      required this.color,
      required this.isReply,
      this.maxLines,
      this.overFlow});

  final String message;
  final MessageEnum type;
  final Color color;
  final bool isReply;
  final int? maxLines;
  final TextOverflow? overFlow;

  @override
  Widget build(BuildContext context) {
    Widget messageToShow() {
      switch (type) {
        case MessageEnum.text:
          return Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
            maxLines: maxLines,
            overflow: overFlow,
          );
        case MessageEnum.image:
          return isReply
              ? const Icon(Icons.image)
              : CachedNetworkImage(
                  imageUrl: message,
                  fit: BoxFit.cover,
                );
        case MessageEnum.video:
          return isReply
              ? const Icon(Icons.video_collection)
              : VideoPlayerWidget(
                  videoUrl: message,
                  color: color,
                );
        case MessageEnum.audio:
          return isReply
              ? const Icon(Icons.audio_file)
              : AudioPlayerWidget(
                  audioUrl: message,
                  color: color,
                );
        default:
          return Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
            maxLines: maxLines,
            overflow: overFlow,
          );
      }
    }

    return messageToShow();
  }
}
