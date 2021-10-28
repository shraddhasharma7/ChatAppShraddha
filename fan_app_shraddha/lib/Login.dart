import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';
import 'SignUp.dart';
import 'authClass.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '', _password = '';

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        print(user);

        Navigator.pushReplacementNamed(context, "/");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
  }

  login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      AuthClass authClassObj = new AuthClass();
      authClassObj.signIN(email: _email, password: _password);
      /*
      try {
        await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      } catch (e) {
        showError(e.toString());
        print(e);
      }*/
    }
  }

  showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  navigateToSignUp() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      child: TextFormField(
                        validator: (input) {
                          if (input!.isEmpty) return 'Enter Email';
                        },
                        decoration: InputDecoration(
                            labelText: 'Email', prefixIcon: Icon(Icons.email)),
                        onSaved: (input) => _email = input!,
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        validator: (input) {
                          if (input!.isEmpty) return 'Enter Email';
                        },
                        decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.email)),
                        obscureText: true,
                        onSaved: (input) => _password = input!,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: login,
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                  ],
                ),
              ),
            ),
            GestureDetector(
              child: Text('Create an Account?'),
              onTap: navigateToSignUp,
            )
          ],
        ),
      ),
    );
  }
}
