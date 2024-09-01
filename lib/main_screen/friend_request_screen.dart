import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/widgets/app_bar_back_button.dart';
import 'package:flutter_app_chat/widgets/friend_lists.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
      ),
      body: Column(
        children: [
          CupertinoSearchTextField(
            placeholder: 'Search',
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              print(value);
            },
          ),
          const Expanded(
            child: FriendList(
              viewType: FriendViewType.friendRequests,
            ),
          ),
        ],
      ),
    );
  }
}
