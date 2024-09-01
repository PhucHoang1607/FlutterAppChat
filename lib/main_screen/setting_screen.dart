import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/widgets/app_bar_back_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDarkMode = false;

  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>();
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: Text(
          'Setting',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          currentUser.uid == uid
              ? IconButton(
                  onPressed: () async {
                    //create a dialog to confirm logout
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Log out'),
                          content:
                              const Text('Are you sure you want to logout'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await context
                                    .read<AuthenticationProvider>()
                                    .logout()
                                    .whenComplete(() {
                                  Navigator.pop(context);
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      Constants.logInScreen, (route) => false);
                                });
                              },
                              child: const Text('Log out'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout))
              : const SizedBox()
        ],
      ),
      body: Center(
        child: Card(
          child: SwitchListTile(
            title: Text('Dark Mode'),
            value: isDarkMode,
            secondary: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              child: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              if (value) {
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            },
          ),
        ),
      ),
    );
  }
}
