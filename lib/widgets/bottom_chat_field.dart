import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/provider/chat_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField(
      {super.key,
      required this.contactUID,
      required this.contactName,
      required this.contactImage,
      required this.groupId});

  final String contactUID;
  final String contactName;
  final String contactImage;
  final String groupId;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late TextEditingController _textEditingController;
  late FocusNode _foucusNode;

  @override
  void initState() {
    // TODO: implement initState
    _textEditingController = TextEditingController();
    _foucusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _textEditingController.dispose();
    _foucusNode.dispose();
    super.dispose();
  }

  //Send Text Message to FireStore
  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendTextMessage(
        sender: currentUser,
        contactUID: widget.contactUID,
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        message: _textEditingController.text,
        messageType: MessageEnum.text,
        groupId: widget.groupId,
        onSucess: () {
          _textEditingController.clear();
          _foucusNode.requestFocus();
        },
        onError: (error) {
          showSnackBar(context, error);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Theme.of(context).focusColor,
        //border: ,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              showBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: 200,
                      child: const Center(
                        child: Text('Attachment'),
                      ),
                    );
                  });
            },
            icon: const Icon(Icons.attachment),
          ),
          Expanded(
            child: TextFormField(
              controller: _textEditingController,
              focusNode: _foucusNode,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  //borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: sendTextMessage,
            child: Container(
              margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).primaryColor),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
