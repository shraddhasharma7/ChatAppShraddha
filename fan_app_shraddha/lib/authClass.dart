import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'constant.dart';

class AuthClass {
  //FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _verificationId;
  //Create Account
  /*
  Future<String> createAccount({String? email, String? password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "Account created";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return "Error occurred";
    }
    return '';
  }*/

  //Sign in user
  Future<String> signIN(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Welcome";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
    return '';
  }

  //google sign up
  Future<UserCredential> googleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        final UserCredential user =
            await _auth.signInWithCredential(credential);

        // await Navigator.pushReplacementNamed(context, "/");

        return user;
      } else {
        throw StateError('Missing Google Auth Token');
      }
    } else
      throw StateError('Sign in Aborted');
  }

  //Facebook
  Future<UserCredential> signInWithFacebook() async {
    final AccessToken result = await FacebookAuth.instance.login();

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.token);

    return await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
  }

  //Anonymous
  Future<UserCredential> anonymousSignIn() async {
    return _auth.signInAnonymously();
  }

  //phone number

  Future<String> send_code(String phone) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {},
      codeSent: (String verificationId, int? forceResendingToken) {
        _verificationId = verificationId;
      },
      verificationFailed: (FirebaseAuthException error) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return _verificationId;
  }

  Future<void> verify(String code, String verid) async {
    print('verid: ' + _verificationId);

    AuthCredential credential = PhoneAuthProvider.credential(
        smsCode: code, verificationId: _verificationId);

    await _auth.signInWithCredential(credential);
  }
  //Signout

  signOut() {
    _auth.signOut();
  }
}
