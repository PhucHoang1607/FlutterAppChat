import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //cupertino search bar
            const Padding(
              padding: EdgeInsets.all(8),
              child: CupertinoSearchTextField(placeholder: 'Search'),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: context
                    .read<AuthenticationProvider>()
                    .getAllUserStream(userId: currentUser.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Text('Loading'));
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return ListTile(
                        leading: userImageWidget(
                            imageUrl: data[Constants.image],
                            radius: 40,
                            onTap: () {}),
                        title: Text(data[Constants.name]),
                        subtitle: Text(
                          data[Constants.aboutMe],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          //Navigate to this user's profile screen
                          Navigator.pushNamed(
                            context,
                            Constants.profileScreen,
                            arguments:
                                document.id, //replace : data[Constants.uid]
                          );
                        },
                      );
                    }).toList(),
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
