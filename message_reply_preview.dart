import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/provider/chat_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      final messageReply = chatProvider.messageReplyModel;
      final isMe = messageReply!.isMe;
      final type = messageReply.messageType;

      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ListTile(
          title: Text(
            isMe ? 'You' : messageReply.senderName,
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          subtitle: messageToShow(type: type, message: messageReply.message),
          trailing: IconButton(
            onPressed: () {
              chatProvider.setMessageReplyModel(null);
            },
            icon: const Icon(Icons.close),
          ),
        ),
      );
    });
  }
}
