import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/main_screen/my_chats_screen.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  final List<Widget> pages = const [
    MyChatsScreen(),
    GroupScreen(),
    PeopleScreen(),
  ];
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    switch (state) {
      case AppLifecycleState.resumed:
        // user comes back to the app
        // update user status to online
        context.read<AuthenticationProvider>().updateUserStatus(
              value: true,
            );
        break;
      case AppLifecycleState.inactive:
        context.read<AuthenticationProvider>().updateUserStatus(
              value: false,
            );
        break;
      case AppLifecycleState.paused:
        context.read<AuthenticationProvider>().updateUserStatus(
              value: false,
            );
        break;
      case AppLifecycleState.detached:
        context.read<AuthenticationProvider>().updateUserStatus(
              value: false,
            );
        break;
      case AppLifecycleState.hidden:
        context.read<AuthenticationProvider>().updateUserStatus(
              value: false,
            );
        break;
      // app is inactive, paused, detached or hidden
      // update user status to offline

      default:
        // handle other states
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

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
        },
      ),
    );
  }
}
