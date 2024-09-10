import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zomato_clone/features/loginandsignup/repository/login_signup_repository.dart';
import 'package:zomato_clone/common/models/pair.dart';
import 'package:zomato_clone/common/models/user.dart';

final loginSignUpControllerProvider = Provider(
    (ref) => LoginSignUpController(ref.watch(loginSignUpRepositoryProvider)));

class LoginSignUpController {
  final LoginSignUpRepository repository;
  LoginSignUpController(this.repository);

  Future<Pair<Pair<UserData, bool>?, String?>>
      signInOrSignUpWithGoogle() async {
    return repository.signInOrSignUpWithGoogle();
  }

  Future<Pair<Pair<UserData, bool>?, String?>>
      signInOrSignUpWithFacebook() async {
    return repository.signInOrSignUpWithFacebook();
  }

  Future<void> signInOrSignUpWithPhone(
    String phoneNumber,
    void Function(String verificationId, int? resendToken) codeSentCallback,
  ) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        // Auto-sign-in if credential is automatically resolved
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception("Phone number verification failed: ${e.message}");
      },
      codeSent: codeSentCallback,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> verifyOTP(String verificationId, String otp) async {
    return repository.verifyOTP(verificationId: verificationId, userOTP: otp);
  }

  Stream<int> getResendTime() async* {
    for (int i = 5; i >= 0; i--) {
      await Future<void>.delayed(const Duration(seconds: 1));
      yield i;
    }
  }

  bool get isUserSigned => repository.isUserSignedIn();
}
