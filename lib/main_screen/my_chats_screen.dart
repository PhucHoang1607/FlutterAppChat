import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/last_message_model.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/provider/chat_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                print(value);
              },
            ),
            Expanded(
              //STREAM THE last messages,
              child: StreamBuilder<List<LastMessageModel>>(
                stream: context.read<ChatProvider>().getChatsListStream(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    final chatsList = snapshot.data!;
                    return ListView.builder(
                      itemCount: chatsList.length,
                      itemBuilder: (context, index) {
                        final chat = chatsList[index];
                        final type = chat.messageType;
                        final dateTimeSent =
                            formatDate(chat.timeSent, [hh, ":", nn, ' ', am]);
                        //check if the last messag3e is me
                        final isMe = chat.senderUID == uid;

                        //did the last messsage correctly
                        final lastMessage =
                            isMe ? 'You: ${chat.message}' : chat.message;
                        return ListTile(
                          leading: userImageWidget(
                              imageUrl: chat.contactImage,
                              radius: 40,
                              onTap: () {}),
                          contentPadding: EdgeInsets.zero,
                          title: Text(chat.contactName),
                          subtitle:
                              messageToShow(type: type, message: lastMessage),
                          trailing: Text(dateTimeSent),
                          onTap: () {
                            Navigator.pushNamed(context, Constants.chatScreen,
                                arguments: {
                                  Constants.contactUID: chat.contactUID,
                                  Constants.contactName: chat.contactName,
                                  Constants.contactImage: chat.contactImage,
                                  Constants.groupId: '',
                                });
                            print(type);
                          },
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('No chats yet'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
