import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/authentication/landing_screen.dart';
import 'package:flutter_app_chat/authentication/login_screen.dart';
import 'package:flutter_app_chat/authentication/otp_screen.dart';
import 'package:flutter_app_chat/authentication/user_information.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/main_screen/chat_screen.dart';
import 'package:flutter_app_chat/main_screen/friend_request_screen.dart';
import 'package:flutter_app_chat/main_screen/friend_screen.dart';
import 'package:flutter_app_chat/main_screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app_chat/main_screen/profile_screen.dart';
import 'package:flutter_app_chat/main_screen/setting_screen.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MainApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (ThemeData light, ThemeData dark) => MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: dark,
        title: 'Flutter Chat App',
        theme: light,
        //home: UserInformationScreen(),
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.logInScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) =>
              const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.settingsScreen: (context) => const SettingScreen(),
          Constants.friendsScreen: (context) => const FriendScreen(),
          Constants.friendRequestsScreen: (context) =>
              const FriendRequestScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
        },
      ),
    );
  }
}
