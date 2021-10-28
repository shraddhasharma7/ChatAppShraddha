import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' as io;
import 'databaseService.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _name, _email, _password, _lastName, _bio, _hometown, _age;
  io.File? file;
  checkAuthentication() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        //Navigator.pushReplacementNamed(context, "/");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        UserCredential user = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        if (user != null) {
          await _auth.currentUser.updateProfile(displayName: _name);
          uploadFile(user.user.uid);
          /* FirebaseFirestore.instance.collection('userList').add({
            'name': _name,
            'email': _email,
            'user id': user.user.uid,
            'role': "customer",
            'surname': _lastName,
            'date': new DateTime.now()
          });*/
        }
      } catch (e) {
        showError(e.toString());
        print(e);
      }
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
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final path = result.files.single.path;
    setState(() => file = io.File(path));
//uploadFile(userID);
  }

  Future uploadFile(String userID) async {
    if (file == null) return;
    final fileName = file!.path; //basename(file!.path);
    final destination = 'files/$userID';
    final ref = FirebaseStorage.instance.ref(destination);
    UploadTask uploadTask = ref.putFile(file);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    print(imageUrl.toString());
    await DatabaseService(uid: userID)
        .updateUserData(_name, imageUrl.toString(), _bio, _hometown, _age);
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: TextFormField(
                              validator: (input) {
                                if (input!.isEmpty) return 'Enter Name';
                              },
                              decoration: InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.person),
                              ),
                              onSaved: (input) => _name = input!),
                        ),
                        Container(
                          child: TextFormField(
                              validator: (input) {
                                if (input!.isEmpty) return 'Enter Last Name';
                              },
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                prefixIcon: Icon(Icons.person),
                              ),
                              onSaved: (input) => _lastName = input!),
                        ),
                        Container(
                          child: TextFormField(
                              validator: (input) {
                                if (input!.isEmpty) return 'Enter Email';
                              },
                              decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email)),
                              onSaved: (input) => _email = input!),
                        ),
                        Container(
                          child: TextFormField(
                              validator: (input) {
                                if (input!.isEmpty) return 'Enter Home town';
                              },
                              decoration: InputDecoration(
                                  labelText: 'Home Town',
                                  prefixIcon: Icon(Icons.home)),
                              onSaved: (input) => _hometown = input!),
                        ),
                        Container(
                          child: TextFormField(
                              validator: (input) {
                                if (input!.isEmpty) return 'Enter age';
                              },
                              decoration: InputDecoration(
                                  labelText: 'Age',
                                  prefixIcon:
                                      Icon(Icons.calendar_view_day_rounded)),
                              onSaved: (input) => _age = input!),
                        ),
                        Container(
                          child: TextFormField(
                              validator: (input) {
                                if (input!.isEmpty) return 'Enter Bio';
                              },
                              decoration: InputDecoration(
                                  labelText: 'Bio',
                                  prefixIcon: Icon(Icons.info)),
                              onSaved: (input) => _bio = input!),
                        ),
                        Container(
                          child: TextFormField(
                              validator: (input) {
                                if (input != null) {
                                  if (input.length < 6)
                                    return 'Provide Minimum 6 Character';
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              onSaved: (input) => _password = input!),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: file == null
                              ? Text('Select an image')
                              : enableUpload(),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: selectFile,
                            child: Text(
                              'Select Image',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                        SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: signUp,
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: [
          Image.file(file!, height: 100, width: 100),
        ],
      ),
    );
  }
}
