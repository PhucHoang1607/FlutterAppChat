import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/model/user_model.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/utilities/assets_manager.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';
import 'package:flutter_app_chat/widgets/app_bar_back_button.dart';
import 'package:flutter_app_chat/widgets/display_user_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _nameController = TextEditingController();
  File? finalFileImage;
  String userImage = '';

  @override
  void dispose() {
    // TODO: implement dispose
    _btnController.stop();
    _nameController.dispose();
    super.dispose();
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
        fromCamera: fromCamera,
        onFail: (String message) {
          showSnackBar(context, message);
        });
    //crop Image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      //popTheDialog();

      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      } else {
        //popTheDialog();
      }
    }
  }

  void showBottomSheetImage() {
    showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height / 5,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      selectImage(true);
                    },
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                  ),
                  ListTile(
                    onTap: () {
                      selectImage(false);
                    },
                    leading: const Icon(Icons.image),
                    title: const Text('Gallery'),
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.of(context).pop();
        }),
        centerTitle: true,
        title: const Text('User Information'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              DisplayUserImage(
                  finalFileImage: finalFileImage,
                  radius: 60,
                  onPressed: showBottomSheetImage),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: _btnController,
                  onPressed: () {
                    _btnController.success();
                    //Save user Information data to Firestore
                    if (_nameController.text.isEmpty ||
                        _nameController.text.length < 3) {
                      showSnackBar(context, 'Please enter your name');
                      _btnController.reset();
                      return;
                    }
                    saveUserDataToFireStore();
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Theme.of(context).primaryColor,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Save user data to Firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();
    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: 'Hey there, I\'m using the app chat',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendUIDs: [],
      friendRequestsUIDs: [],
      sendFriendRequestsUIDs: [],
    );

    authProvider.saveUserDataToFireStore(
        userModel: userModel,
        fileImage: finalFileImage,
        onSuccess: () async {
          _btnController.success();
          // await Future.delayed(const Duration(seconds: 1));
          // _btnController.reset();

          //Save user data to shared Preference
          await authProvider.saveUserDataToSharedPreferences();

          navigatorToHomeScreen();
        },
        onFail: () async {
          _btnController.error();
          showSnackBar(context, 'Fail to save user Data');
          await Future.delayed(const Duration(seconds: 1));
          _btnController.reset();
        });
  }

  void navigatorToHomeScreen() {
    //navigate to homeScreen
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Constants.homeScreen, (route) => false);
  }
}
