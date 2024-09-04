import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/widgets/app_bar_back_button.dart';
import 'package:flutter_app_chat/widgets/friend_lists.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        title: const Text('Friend Screen'),
        centerTitle: true,
      ),
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
            const Expanded(
              child: FriendList(
                viewType: FriendViewType.friends,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
