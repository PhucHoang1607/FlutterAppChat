import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';

//This widget use what to show the Type of message
class DisplayMessageType extends StatelessWidget {
  const DisplayMessageType(
      {super.key,
      required this.message,
      required this.type,
      required this.color,
      this.maxLines,
      this.overFlow});

  final String message;
  final MessageEnum type;
  final Color color;
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
          return CachedNetworkImage(
            imageUrl: message,
            fit: BoxFit.cover,
          );
        case MessageEnum.video:
          return Image.network(
            message,
            fit: BoxFit.cover,
          );
        case MessageEnum.audio:
          return Image.network(
            message,
            fit: BoxFit.cover,
          );
        default:
          return Text(
            message,
            style: const TextStyle(
              color: Colors.white,
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
