import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/main_screen/chats_list_screen.dart';
import 'package:flutter_app_chat/main_screen/group_screen.dart';
import 'package:flutter_app_chat/main_screen/people_screen.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/utilities/assets_manager.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  final List<Widget> pages = const [
    ChatsListScreen(),
    GroupScreen(),
    PeopleScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: userImageWidget(
                imageUrl: authProvider.userModel!.image,
                radius: 20,
                onTap: () {
                  //Navigate to user Profile with uid as argument
                  Navigator.pushNamed(context, Constants.profileScreen,
                      arguments: authProvider.userModel!.uid);
                }),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2), label: 'Chats'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.group), label: 'Groups'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.globe), label: 'People')
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          //animted to Page
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
          setState(() {
            currentIndex = index;
          });
          print(currentIndex);
        },
      ),
    );
  }
}
