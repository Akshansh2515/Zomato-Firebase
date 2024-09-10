import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zomato_clone/common/constants/colors.dart';
import 'package:zomato_clone/common/utils/utils.dart';
import 'package:zomato_clone/common/widgets/custom_button.dart';
import 'package:zomato_clone/features/loginandsignup/controller/login_signup_controller.dart';
import 'package:zomato_clone/features/loginandsignup/screens/verify_otp_screen.dart';
import 'package:zomato_clone/features/home/main_home/screens/main_home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = "/login-screen";

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneEditingController = TextEditingController();
  var isSigning = false;
  String selectedCountryCode = "+91"; // Default country code

  // List of country codes
  final List<String> countryCodes = [
    "+91", // India
    "+1", // USA
    "+44", // UK
    "+61", // Australia
    "+81", // Japan
    "+49", // Germany
    // Add more country codes here
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  void googleSignInOrSignUp() async {
    showLoaderDialog(context);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _handleSignInFailure("User canceled the sign-in");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _navigateToMainHomeScreen();
      } else {
        _handleSignInFailure("Google Sign-In Failed");
      }
    } catch (e) {
      _handleSignInFailure("Error: ${e.toString()}");
    }
  }

  void _handleSignInFailure(String message) {
    // Close the loading dialog and show error message
    Navigator.pop(context);
    showSnackBar(context, message);
  }

  void _navigateToMainHomeScreen() {
    // Close the loading dialog and navigate to the main home screen
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      MainHomeScreen.routeName,
      (route) => false,
    );
  }

  // Sign in with Phone
  void phoneSignInOrSignUp() async {
    if (phoneEditingController.text.isNotEmpty) {
      showLoaderDialog(context);

      try {
        ref.read(loginSignUpControllerProvider).signInOrSignUpWithPhone(
          "$selectedCountryCode${phoneEditingController.text}",
          (verificationId, resendToken) {
            Navigator.pop(context);
            final args = <String, dynamic>{
              "verificationId": verificationId,
              "resendToken": resendToken,
              "phoneNumber":
                  "$selectedCountryCode${phoneEditingController.text}",
            };
            Navigator.pushNamed(context, VerifyOTPScreen.routeName,
                arguments: args);
          },
        );
      } catch (e) {
        Navigator.pop(context);
        showSnackBar(context, e.toString());
      }
    } else {
      showSnackBar(context, "Please enter a valid phone number");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: double.infinity,
            height: size.height * 0.4,
            child: Image.asset(
              "assets/images/login_image_1.jpg",
              fit: BoxFit.fitWidth,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
            child: Text(
              "India's #1 Food Delivery and Dining App",
              style: textTheme.displayLarge?.copyWith(
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 1,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: lightGrey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Log in or sign up",
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 14,
                      color: grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: lightGrey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 25),
            child: Row(
              children: [
                // Dropdown for country codes
                DropdownButton<String>(
                  value: selectedCountryCode,
                  items: countryCodes.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(code),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCountryCode = value!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 4.0)
                        .copyWith(left: 10),
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: midGrey, width: 1.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: TextFormField(
                              style: textTheme.bodyMedium,
                              controller: phoneEditingController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: "Enter Phone Number",
                                hintStyle: textTheme.bodyLarge?.copyWith(
                                  color: midLightGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child:
                CustomButton(text: "Continue", onPressed: phoneSignInOrSignUp),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: lightGrey,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "or",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: grey),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: lightGrey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: googleSignInOrSignUp,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(lightGrey),
                  shape: WidgetStateProperty.all(
                    const CircleBorder(),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    "assets/images/google_icon.png",
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
              // Other social media buttons (like Facebook) can be added here
            ],
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
        ],
      ),
    );
  }
}
