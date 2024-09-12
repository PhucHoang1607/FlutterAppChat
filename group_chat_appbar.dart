import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/model/user_model.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:provider/provider.dart';

// class ChatAppBar extends StatefulWidget {
//   const ChatAppBar({super.key, required this.groupId});

//   final String groupId;

//   @override
//   State<ChatAppBar> createState() => _ChatAppBarState();
// }

// class _ChatAppBarState extends State<ChatAppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: context
//           .read<AuthenticationProvider>()
//           .userStream(userId: widget.groupId),
//       builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return const Center(child: Text('Something went wrong'));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final groupModel =
//             GroupModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

//         return Row(
//           children: [
//             userImageWidget(
//               imageUrl: groupModel.groupImage,
//               radius: 20,
//               onTap: () {
//                 //Navigate to group setting screen
//               },
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(groupModel.groupName),
//                 const Text(
//                   //userModel.isOnline ? 'Online' : 'LastSeen ${}',
//                   'Group escription',
//                   style: TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
