import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'authClass.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthClass authClassObj = new AuthClass();
  googleSignIn() async {
    //Future<UserCredential> resultOfGoogleSignIn =
    authClassObj.googleSignIn().then((UserCredential value) {
      Navigator.pushReplacementNamed(context, "/");
      //return resultOfGoogleSignIn;
    });
  }

  facebookSignIn() async {
    authClassObj.signInWithFacebook().then((UserCredential value) {
      Navigator.pushReplacementNamed(context, "/");
    });
  }

  anonymousSignIn() async {
    authClassObj.anonymousSignIn().then((UserCredential value) {
      Navigator.pushReplacementNamed(context, "/");
    });
  }

  String _verid = '';
  Future<void> _phoneSignIn(BuildContext context) async {
    TextEditingController phone = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Enter your Phone Number'),
              content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          //valueText = value;
                        });
                      },
                      controller: phone,
                      decoration: InputDecoration(hintText: "Enter Phone"),
                    ),
                    Expanded(
                      child: OTPTextField(
                        length: 6,
                        width: MediaQuery.of(context).size.width,
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldWidth: 30,
                        fieldStyle: FieldStyle.underline,
                        outlineBorderRadius: 10,
                        style: TextStyle(fontSize: 20),
                        onChanged: (pin) {
                          print("Changed: " + pin);
                        },
                        onCompleted: (pin) {
                          authClassObj.verify(pin, _verid).then((value) =>
                              Navigator.pushReplacementNamed(context, "/"));
                        },
                      ),
                    )
                  ]),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      child: Text('Cancel'),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                          //Navigator.pushNamed(context, '/Login');
                        });
                      },
                    ),
                    FlatButton(
                      color: Colors.blueAccent,
                      textColor: Colors.white,
                      child: Text('Get Code'),
                      onPressed: () {
                        setState(() {
                          _verid = authClassObj
                              .send_code(phone.text.trim())
                              .toString();
                        });
                      },
                    ),
                  ],
                )
              ]);
        });
  }

  navigateToLogin() async {
    Navigator.pushReplacementNamed(context, "Login");
  }

  navigateToRegister() async {
    Navigator.pushReplacementNamed(context, "SignUp");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fan App'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            RichText(
                text: TextSpan(
                    text: 'Welcome',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: navigateToLogin,
                    child: Text('LOGIN',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                    onPressed: navigateToRegister,
                    child: Text(
                      'SignUp',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            SignInButton(
              Buttons.Google,
              text: "Sign up with Google",
              onPressed: googleSignIn,
            ),
            SizedBox(
              height: 20,
            ),
            SignInButton(
              Buttons.Facebook,
              text: "Sign up with faceBook",
              onPressed: facebookSignIn,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: anonymousSignIn,
                child: Text('Anonymous SignIn',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  _phoneSignIn(context);
                },
                child: Text('Phone Number SignIn',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)))
          ],
        ),
      ),
    );
  }
}
