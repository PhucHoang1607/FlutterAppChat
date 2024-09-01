import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/constants.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Get the argument
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;

    final authProvider = context.watch<AuthenticationProvider>();

    final defaultTheme = PinTheme(
        width: 56,
        height: 60,
        textStyle:
            GoogleFonts.openSans(fontSize: 22, fontWeight: FontWeight.w600),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.transparent)));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Verification',
                  style: GoogleFonts.openSans(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Enter the OTP code send to you at the number you provide',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  phoneNumber,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 60,
                  child: Pinput(
                    length: 6,
                    controller: controller,
                    focusNode: focusNode,
                    defaultPinTheme: defaultTheme,
                    onCompleted: (pin) {
                      setState(() {
                        otpCode = pin;
                      });
                      //Verrify OTP Code
                      verifyOTPCode(
                          verificationId: verificationId, otpCode: otpCode!);
                    },
                    focusedPinTheme: defaultTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.deepPurple),
                      ),
                    ),
                    errorPinTheme: defaultTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
                authProvider.isSuccessful
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
                authProvider.isLoading
                    ? const SizedBox.shrink()
                    : Text(
                        'Didn\'t receive the code ?',
                        style: GoogleFonts.openSans(fontSize: 16),
                      ),
                const SizedBox(
                  height: 10,
                ),
                authProvider.isLoading
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () {
                          //TODO resend OTP code
                        },
                        child: Text(
                          'Resend the code',
                          style: GoogleFonts.openSans(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTPCode(
      {required String verificationId, required String otpCode}) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
        verificationId: verificationId,
        otpCode: otpCode,
        context: context,
        onSuccess: () async {
          //Check if user exist in firestore
          bool userExists = await authProvider.checkUserExist();
          if (userExists) {
            //2. if user exists, navigate to home screen

            // * get user information from firestore
            await authProvider.getUserDataFromFireStore();
            // * save user information to provider / shared preference
            await authProvider.saveUserDataToSharedPreferences();

            //*Navigator to homeScreen
            navigate(userExists: true);
          } else {
            //3. if user doesn;t exist, navigate to information screen
            navigate(userExists: false);
          }
        });
  }

  void navigate({required bool userExists}) {
    if (userExists) {
      //Navigate to Home Screen and remove all the routes
      Navigator.pushNamedAndRemoveUntil(
          context, Constants.homeScreen, (route) => false);
    } else {
      //Navigate to user information Screen
      Navigator.pushNamed(
        context,
        Constants.userInformationScreen,
      );
    }
  }
}
