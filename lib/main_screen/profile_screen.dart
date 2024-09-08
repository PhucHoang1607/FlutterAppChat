import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/user_model.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:flutter_app_chat/widgets/app_bar_back_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    //get user data from argument
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          currentUser.uid == uid
              ? IconButton(
                  onPressed: () async {
                    //Navigate to Setting screen with uid as a argument
                    await Navigator.pushNamed(
                      context,
                      Constants.settingsScreen,
                      arguments: uid,
                    );
                  },
                  icon: const Icon(Icons.settings))
              : const SizedBox()
        ],
      ),
      body: StreamBuilder(
        stream: context.read<AuthenticationProvider>().userStream(userId: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                    imageUrl: userModel.image,
                    radius: 60,
                    onTap: () {},
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        userModel.name,
                        style: GoogleFonts.openSans(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      currentUser.uid == userModel.uid
                          ? Text(
                              userModel.phoneNumber,
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(
                        height: 20,
                      ),
                      buildFriendRequestButton(
                          currentUser: currentUser, userModel: userModel),
                      const SizedBox(
                        height: 10,
                      ),
                      buildFriendButton(
                          currentUser: currentUser, userModel: userModel),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'About me',
                            style: GoogleFonts.openSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.deepPurple),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        userModel.aboutMe,
                        style: GoogleFonts.openSans(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  //Friend request Button
  Widget buildFriendRequestButton(
      {required UserModel currentUser, required UserModel userModel}) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendRequestsUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          //Navigate to friend request screen
          Navigator.pushNamed(context, Constants.friendRequestsScreen);
        },
        label: 'View Friend Request',
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).colorScheme.primary,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  //Friends button
  Widget buildFriendButton(
      {required UserModel currentUser, required UserModel userModel}) {
    if (currentUser.uid == userModel.uid && userModel.friendUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          //Navigate to friend screen
          Navigator.pushNamed(context, Constants.friendsScreen);
        },
        label: 'View Friend',
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).colorScheme.primary,
      );
    } else {
      if (currentUser.uid != userModel.uid) {
        //show cancel friend request button if the user send us the friend request

        if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
          return buildElevatedButton(
            onPressed: () async {
              //Send friend request
              await context
                  .read<AuthenticationProvider>()
                  .cancelFriendRequest(friendId: userModel.uid)
                  .whenComplete(() {
                showSnackBar(
                  context,
                  'Friends Request Cancel',
                );
              });
            },
            label: 'Cancel friend request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).colorScheme.primary,
          );
        } else if (userModel.sendFriendRequestsUIDs.contains(currentUser.uid)) {
          return buildElevatedButton(
            onPressed: () async {
              //Send friend request

              await context
                  .read<AuthenticationProvider>()
                  .acceptFriendRequest(friendId: userModel.uid)
                  .whenComplete(() {
                showSnackBar(
                  context,
                  'You are now friend ${userModel.name}',
                );
              });
            },
            label: 'Accept friend request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).colorScheme.primary,
          );
        } else if (userModel.friendUIDs.contains(currentUser.uid)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildElevatedButton(
                onPressed: () async {
                  //show remove friend and done it
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Unfriend',
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          'Are you sure you want to unfriend ${userModel.name} ?',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              //remove friend

                              await context
                                  .read<AuthenticationProvider>()
                                  .removeFriend(friendId: userModel.uid)
                                  .whenComplete(() {
                                showSnackBar(
                                    context, 'You are no longer friends');
                              });
                            },
                            child: const Text('yes'),
                          ),
                        ],
                      );
                    },
                  );
                },
                label: 'Unfriend',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor: Theme.of(context).cardColor,
                textColor: Colors.white,
              ),
              buildElevatedButton(
                onPressed: () async {
                  //Navigate to chat screen
                  Navigator.pushNamed(
                    context,
                    Constants.chatScreen,
                    arguments: {
                      Constants.contactUID: userModel.uid,
                      Constants.contactName: userModel.name,
                      Constants.contactImage: userModel.image,
                      Constants.groupId: '',
                    },
                  );
                },
                label: 'Chat',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          );
        } else {
          return buildElevatedButton(
            onPressed: () async {
              //Send friend request
              await context
                  .read<AuthenticationProvider>()
                  .sendFriendRequest(friendId: userModel.uid)
                  .whenComplete(() {
                showSnackBar(
                  context,
                  'Friends Request Send',
                );
              });
            },
            label: 'Send friend request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).colorScheme.primary,
          );
        }

        //show send friend request button
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  //Build Elevated Button
  Widget buildElevatedButton(
      {required VoidCallback onPressed,
      required String label,
      required double width,
      required Color backgroundColor,
      required Color textColor}) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}
