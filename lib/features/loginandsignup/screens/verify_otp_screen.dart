import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zomato_clone/common/utils/utils.dart';
import 'package:zomato_clone/common/constants/colors.dart';
import 'package:zomato_clone/features/home/main_home/screens/main_home_screen.dart';

class VerifyOTPScreen extends ConsumerStatefulWidget {
  static const routeName = "/verify-otp-screen";
  final String verificationId;
  final int? resendToken;
  final String phoneNumber;

  const VerifyOTPScreen({
    required this.verificationId,
    required this.resendToken,
    required this.phoneNumber,
    super.key,
  });

  @override
  ConsumerState<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends ConsumerState<VerifyOTPScreen> {
  String otpCode = '';
  bool isLoading = false;
  String? currentVerificationId;
  int? currentResendToken;

  @override
  void initState() {
    super.initState();
    currentVerificationId = widget.verificationId;
    currentResendToken = widget.resendToken;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: textTheme.labelMedium?.copyWith(fontSize: 20),
      decoration: BoxDecoration(
        border: Border.all(color: midGrey),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: black),
      borderRadius: BorderRadius.circular(8),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "OTP Verification",
          style: textTheme.labelSmall?.copyWith(fontSize: 18),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_sharp,
            color: black,
          ),
        ),
        backgroundColor: white,
        elevation: 0,
      ),
      backgroundColor: white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "We have sent a verification code to",
              style: textTheme.bodyLarge?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.phoneNumber,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Pinput(
                defaultPinTheme: defaultPinTheme,
                submittedPinTheme: submittedPinTheme,
                length: 6,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (pin) {
                  otpCode = pin;
                },
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: verifyOTP,
                    child: const Text("Verify OTP"),
                  ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: resendOTP,
              child: const Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }

  // Verify the OTP entered by the user
  Future<void> verifyOTP() async {
    setState(() {
      isLoading = true;
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: currentVerificationId!,
        smsCode: otpCode,
      );

      // Sign in using the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      // Navigate to the MainHomeScreen after successful verification
      Navigator.pushNamedAndRemoveUntil(
        context,
        MainHomeScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "Verification Failed: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Resend the OTP in case the user didn't receive the first one
  Future<void> resendOTP() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        forceResendingToken: currentResendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            MainHomeScreen.routeName,
            (route) => false,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          showSnackBar(context, e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            isLoading = false;
            currentVerificationId = verificationId;
            currentResendToken = resendToken;
          });
          showSnackBar(context, "OTP Resent Successfully");
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;

      showSnackBar(context, "Failed to resend OTP: ${e.toString()}");
    }
  }
}
