import 'package:flutter_app_chat/constants.dart';

class UserModel {
  String uid;
  String name;
  String phoneNumber;
  String image;
  String token;
  String aboutMe;
  String lastSeen;
  String createdAt;
  bool isOnline;
  List<String> friendUIDs;
  List<String> friendRequestsUIDs;
  List<String> sendFriendRequestsUIDs;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.image,
    required this.token,
    required this.aboutMe,
    required this.lastSeen,
    required this.createdAt,
    required this.isOnline,
    required this.friendUIDs,
    required this.friendRequestsUIDs,
    required this.sendFriendRequestsUIDs,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        uid: map[Constants.uid] ?? '',
        name: map[Constants.name] ?? '',
        phoneNumber: map[Constants.phoneNumber] ?? '',
        image: map[Constants.image] ?? '',
        token: map[Constants.token] ?? '',
        aboutMe: map[Constants.aboutMe] ?? '',
        lastSeen: map[Constants.lastSeen] ?? '',
        createdAt: map[Constants.createdAt] ?? '',
        isOnline: map[Constants.isOnline] ?? false,
        friendUIDs: List<String>.from(map[Constants.friendUIDs] ?? []),
        friendRequestsUIDs:
            List<String>.from(map[Constants.friendRequestsUIDs] ?? []),
        sendFriendRequestsUIDs:
            List<String>.from(map[Constants.sendFriendRequestsUIDs] ?? []));
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.phoneNumber: phoneNumber,
      Constants.image: image,
      Constants.token: token,
      Constants.aboutMe: aboutMe,
      Constants.lastSeen: lastSeen,
      Constants.createdAt: createdAt,
      Constants.isOnline: isOnline,
      Constants.friendUIDs: friendUIDs,
      Constants.friendRequestsUIDs: friendRequestsUIDs,
      Constants.sendFriendRequestsUIDs: sendFriendRequestsUIDs
    };
  }
}
