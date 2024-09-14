import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/provider/chat_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:flutter_app_chat/widgets/message_reply_preview.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
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
  FlutterSoundRecord? _soundRecord;
  late TextEditingController _textEditingController;
  late FocusNode _foucusNode;

  File? finalFileImage;
  String filePath = '';

  bool isRecording = false;
  bool isShowSendButton = false;
  bool isSendingAudio = false;
  bool isShowEmojiPicker = false;

  //Hide emoji container
  void hideEmojiContainer() {
    setState(() {
      isShowEmojiPicker = false;
    });
  }

  //show emoji container
  void showEmojiContainer() {
    setState(() {
      isShowEmojiPicker = true;
    });
  }

  //show keyboard
  void showKeyboard() {
    _foucusNode.requestFocus();
  }

  //hide keyboard
  void hideKeyboard() {
    _foucusNode.unfocus();
  }

  //toggle emoji and keyboard container
  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiPicker) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _soundRecord = FlutterSoundRecord();
    _foucusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _soundRecord?.dispose();
    _foucusNode.dispose();
    super.dispose();
  }

  //Check microphone permission
  Future<bool> checkMicrophonePermissions() async {
    bool hasPermission = await Permission.microphone.isGranted;
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      hasPermission = true;
    } else {
      hasPermission = false;
    }
    return hasPermission;
  }

  //Start recording
  void startRecording() async {
    final hasPermission = await checkMicrophonePermissions();
    if (hasPermission) {
      var tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/flutter_sound.aac';
      await _soundRecord!.start(
        path: filePath,
      );
      setState(() {
        isRecording = true;
      });
    }
  }

  //Stop recording
  void stopRecording() async {
    await _soundRecord!.stop();
    setState(() {
      isRecording = false;
      isSendingAudio = true;
    });
    //Send file audio to firestore
    sendFileMessage(messageType: MessageEnum.audio);
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
        fromCamera: fromCamera,
        onFail: (String message) {
          showSnackBar(context, message);
        });
    //crop Image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(cropFilePath) async {
    if (cropFilePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: cropFilePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      //popTheDialog();

      if (croppedFile != null) {
        filePath = croppedFile.path;
        // send image message to firestore
        sendFileMessage(messageType: MessageEnum.image);
      }
    }
  }

  void selectVideo() async {
    File? fileVideo = await pickVideo(onFail: (String message) {
      showSnackBar(context, message);
    });

    popContext();

    if (fileVideo != null) {
      filePath = fileVideo.path;
      sendFileMessage(messageType: MessageEnum.video);
    }
  }

  void sendFileMessage({required MessageEnum messageType}) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendFileMessage(
        sender: currentUser,
        contactUID: widget.contactUID,
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        file: File(filePath),
        messageType: messageType,
        groupId: widget.groupId,
        onSucess: () {
          _textEditingController.clear();
          _foucusNode.unfocus();
          setState(() {
            isSendingAudio = false;
          });
        },
        onError: (error) {
          setState(() {
            isSendingAudio = false;
          });
          showSnackBar(context, error);
        });
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
          //_textEditingController.delete();
          _textEditingController.clear();
          _foucusNode.unfocus();
        },
        onError: (error) {
          showSnackBar(context, error);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messageReply = chatProvider.messageReplyModel;
        final isMessageReply = messageReply != null;
        return Column(
          children: [
            Container(
              //height: 50,
              alignment: Alignment.center,
              //padding: const EdgeInsets.only(left: 10),
              margin:
                  const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 0),
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2, color: Theme.of(context).colorScheme.primary),

                // borderRadius: const BorderRadius.only(
                //   topLeft: Radius.circular(20),
                //   topRight: Radius.circular(20),
                // ),
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).cardColor,
                //border: ,
              ),
              child: Column(
                children: [
                  isMessageReply
                      ? const MessageReplyPreview()
                      : const SizedBox.shrink(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: toggleEmojiKeyboardContainer,
                        icon: Icon(isShowEmojiPicker
                            ? Icons.keyboard_alt
                            : Icons.emoji_emotions_outlined),
                      ),
                      // chatProvider.isLoading
                      //     ? const CircularProgressIndicator()
                      //     :
                      IconButton(
                        onPressed: isSendingAudio
                            ? null
                            : () {
                                showBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return SizedBox(
                                        height: 200,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.camera_alt),
                                                title: const Text('Camera'),
                                                onTap: () {
                                                  selectImage(true);
                                                },
                                              ),
                                              ListTile(
                                                leading:
                                                    const Icon(Icons.image),
                                                title: const Text('Gallery'),
                                                onTap: () {
                                                  selectImage(false);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.video_library),
                                                title: const Text('Video'),
                                                onTap: selectVideo,
                                              )
                                            ],
                                          ),
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
                          onChanged: (value) {
                            setState(() {
                              isShowSendButton = value.isNotEmpty;
                            });
                          },
                          onTap: () {
                            hideEmojiContainer();
                          },
                        ),
                      ),
                      chatProvider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : GestureDetector(
                              onTap: isShowSendButton ? sendTextMessage : null,
                              onLongPress:
                                  isShowSendButton ? null : startRecording,
                              onLongPressUp: stopRecording,
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.deepPurple),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: isShowSendButton
                                      ? const Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : const Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),

            //show emoji container
            isShowEmojiPicker
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: EmojiPicker(
                      onEmojiSelected: (category, Emoji emoji) {
                        _textEditingController.text =
                            _textEditingController.text + emoji.emoji;
                        if (!isShowSendButton) {
                          setState(() {
                            isShowSendButton = true;
                          });
                        }
                      },
                      onBackspacePressed: () {
                        _textEditingController.text = _textEditingController
                            .text.characters
                            .skipLast(1)
                            .toString();
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
