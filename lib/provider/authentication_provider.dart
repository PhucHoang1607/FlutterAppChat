import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/user_model.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //Check authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));

    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;

      //get user data from firestore
      await getUserDataFromFireStore();
      //sae user datat to shared preferences
      await saveUserDataToSharedPreferences();
      notifyListeners();
      isSignedIn = true;
    } else {
      isSignedIn = false;
    }
    return isSignedIn;
  }

  //check if user exist
  Future<bool> checkUserExist() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  //update user online status
  Future<void> updateUserStatus({required bool value}) async {
    await _firestore
        .collection(Constants.users)
        .doc(_auth.currentUser!.uid)
        .update({Constants.isOnline: value});
    print(_auth.currentUser!.uid);
  }

  //Get user data from firestore
  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  //save user data to share preference
  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  //get Data from shared Preference
  Future<void> getUserDataFromSharedPreference() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userModelString =
        sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  // Sign In with phone number
  Future<void> signInWithPhoneNumber(
      {required String phoneNumber, required BuildContext context}) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) async {
            _uid = value.user!.uid;
            _phoneNumber = value.user!.phoneNumber;
            _isSuccessful = true;
            _isLoading = true;
            notifyListeners();
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();
          showSnackBar(context, e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          _isLoading = false;
          notifyListeners();
          //Navigate to OTP
          Navigator.of(context).pushNamed(Constants.otpScreen, arguments: {
            Constants.verificationId: verificationId,
            Constants.phoneNumber: phoneNumber,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  //Verify otp code
  Future<void> verifyOTPCode(
      {required String verificationId,
      required String otpCode,
      required BuildContext context,
      required Function onSuccess}) async {
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }).catchError((e) {
      _isSuccessful = false;
      _isLoading = true;
      notifyListeners();
      showSnackBar(context, e.toString());
    });
  }

  //Save user data to firestore
  void saveUserDataToFireStore(
      {required UserModel userModel,
      required File? fileImage,
      required Function onSuccess,
      required Function onFail}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (fileImage != null) {
        String imageUrl = await storeFileToStorage(
            file: fileImage,
            reference: "${Constants.userImages}/${userModel.uid}");

        userModel.image = imageUrl;
      }

      //
      userModel.lastSeen = DateTime.now().millisecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      //Save user Data to firestore
      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());

      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  //store file to storage  and return image url
  Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  //Get user stream
  Stream<DocumentSnapshot> userStream({required String userId}) {
    return _firestore.collection(Constants.users).doc(userId).snapshots();
  }

  //get all user stream
  Stream<QuerySnapshot> getAllUserStream({required String userId}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userId)
        .snapshots();
  }

  //Send friend request
  Future<void> sendFriendRequest({required String friendId}) async {
    try {
      //add our uid to friend request list
      await _firestore.collection(Constants.users).doc(friendId).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([_uid])
      });

      //add friend uid to our friend request sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sendFriendRequestsUIDs: FieldValue.arrayUnion([friendId]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> cancelFriendRequest({required String friendId}) async {
    try {
      //remove our uid from friend request list
      await _firestore.collection(Constants.users).doc(friendId).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });

      //remove friend uid from our friend request sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendId]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  //Accept friend request
  Future<void> acceptFriendRequest({required String friendId}) async {
    //Add our uid to friend list(opponent)
    await _firestore.collection(Constants.users).doc(friendId).update({
      Constants.friendUIDs: FieldValue.arrayUnion([_uid])
    });

    //Add friend uid to our friend List
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendUIDs: FieldValue.arrayUnion([friendId])
    });

    //Remove our uid from friends request list(opponent)
    await _firestore.collection(Constants.users).doc(friendId).update({
      Constants.sendFriendRequestsUIDs: FieldValue.arrayRemove([_uid]),
    });

    //rEMOVE FRIEND UID FROM OUR FRIEND REQUEST SEND LIST
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendId])
    });
  }

  //remove friend
  Future<void> removeFriend({required String friendId}) async {
    await _firestore.collection(Constants.users).doc(friendId).update({
      Constants.friendUIDs: FieldValue.arrayRemove([_uid]),
    });

    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendUIDs: FieldValue.arrayRemove([friendId])
    });
  }

  //Get list of friend
  Future<List<UserModel>> getFriendList(String uid) async {
    List<UserModel> friendsList = [];
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(uid).get();
    List<dynamic> friendsUIDs = documentSnapshot.get(Constants.friendUIDs);

    for (String friendUID in friendsUIDs) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection(Constants.users).doc(friendUID).get();
      UserModel friend =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      friendsList.add(friend);
    }

    return friendsList;
  }

  //get a list of friend request
  Future<List<UserModel>> getFriendRequestsList(String uid) async {
    List<UserModel> friendRequestList = [];

    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(uid).get();

    List<dynamic> friendRequestsUIDs =
        documentSnapshot.get(Constants.friendRequestsUIDs);

    for (String friendRequestUID in friendRequestsUIDs) {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(Constants.users)
          .doc(friendRequestUID)
          .get();
      UserModel friendRequest =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      friendRequestList.add(friendRequest);
    }
    return friendRequestList;
  }

  Future logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }
}
