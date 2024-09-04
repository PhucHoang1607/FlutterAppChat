import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/user_model.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class FriendList extends StatelessWidget {
  const FriendList({
    super.key,
    required this.viewType,
  });

  final FriendViewType viewType;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    final future = viewType == FriendViewType.friends
        ? context.read<AuthenticationProvider>().getFriendList(uid)
        : viewType == FriendViewType.friendRequests
            ? context.read<AuthenticationProvider>().getFriendRequestsList(uid)
            : context.read<AuthenticationProvider>().getFriendList(uid);

    return FutureBuilder<List<UserModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No friend yet"));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              return ListTile(
                contentPadding: const EdgeInsets.only(left: -10),
                leading: userImageWidget(
                  imageUrl: data.image,
                  radius: 40,
                  onTap: () {
                    //Navigator to this friend provide uid as argument
                    Navigator.pushNamed(context, Constants.profileScreen,
                        arguments: data.uid);
                  },
                ),
                title: Text(data.name),
                subtitle: Text(
                  data.aboutMe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if (viewType == FriendViewType.friends) {
                      Navigator.pushNamed(
                        context,
                        Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: data.uid,
                          Constants.contactName: data.name,
                          Constants.contactImage: data.image,
                          Constants.groupId: '',
                        },
                      );
                    } else if (viewType == FriendViewType.friendRequests) {
                      await context
                          .read<AuthenticationProvider>()
                          .acceptFriendRequest(friendId: data.uid)
                          .whenComplete(() {
                        showSnackBar(
                          context,
                          'You are now friend ${data.name}',
                        );
                      });
                    } else {}
                  },
                  child: viewType == FriendViewType.friends
                      ? const Text('Chat')
                      : const Text('Accept'),
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
