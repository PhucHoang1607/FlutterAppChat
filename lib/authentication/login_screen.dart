import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_chat/provider/authentication_provider.dart';
import 'package:flutter_app_chat/utilities/assets_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  Country selectedCountry = Country(
    phoneCode: '84',
    countryCode: '84',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'VietNam',
    example: 'VietNam',
    displayName: 'VietNam',
    displayNameNoCountryCode: 'VN',
    e164Key: '',
  );

  @override
  void dispose() {
    // TODO: implement dispose
    _phoneNumberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    // == Provider.of<AuthenticationProvider>(context, listen: true);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(AssetsManager.chatBubles),
              ),
              Text(
                'Flutter App Chat',
                style: GoogleFonts.openSans(
                    fontSize: 28, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Add your phone number will send you a code to verify',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _phoneNumberController,
                maxLength: 10,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _phoneNumberController.text = value;
                  });
                },
                decoration: InputDecoration(
                    counterText: '',
                    hintStyle: GoogleFonts.openSans(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    hintText: 'Phone Number',
                    prefixIcon: Container(
                      padding: const EdgeInsets.fromLTRB(9, 17, 8, 12),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            countryListTheme: CountryListThemeData(
                                bottomSheetHeight: 600,
                                textStyle: GoogleFonts.openSans(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountry = country;
                              });
                            },
                          );
                        },
                        child: Text(
                          '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                          style: GoogleFonts.openSans(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    suffixIcon: _phoneNumberController.text.length >= 9
                        ? authProvider.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(),
                              )
                            : InkWell(
                                onTap: () {
                                  //TODO Send Code Authen
                                  authProvider.signInWithPhoneNumber(
                                      phoneNumber:
                                          '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                                      context: context);
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  margin: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    //borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
