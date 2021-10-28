import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:mad_assignment_2/authentication.dart';
// import 'package:transparent_image/transparent_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {
  final QueryDocumentSnapshot userData;

  const Profile({Key? key, required QueryDocumentSnapshot this.userData})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List _l = [];

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: ListView(children: [
            SizedBox(height: 10),
            CircleAvatar(
              radius: 50.0,
              child: ClipOval(
                  child: CachedNetworkImage(
                      width: 100,
                      height: 100,
                      imageUrl: widget.userData['profile_pic'])),
            ),
            SizedBox(height: 30),
            Card(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    padding: EdgeInsets.all(10),
                    child: Text('Username :',
                        style: TextStyle(height: 1, fontSize: 18),
                        textAlign: TextAlign.center)),
                Container(
                    padding: EdgeInsets.all(10),
                    child: Text(widget.userData['username'],
                        style: TextStyle(height: 1, fontSize: 18),
                        textAlign: TextAlign.center))
              ]),
            ),
            Card(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    padding: EdgeInsets.all(10),
                    child: Text('Age :',
                        style: TextStyle(height: 1, fontSize: 18),
                        textAlign: TextAlign.center)),
                Container(
                    padding: EdgeInsets.all(10),
                    child: Text(widget.userData['age'],
                        style: TextStyle(height: 1, fontSize: 18),
                        textAlign: TextAlign.center))
              ]),
            ),
            Card(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    padding: EdgeInsets.all(10),
                    child: Text('Home town :',
                        style: TextStyle(height: 1, fontSize: 18),
                        textAlign: TextAlign.center)),
                Container(
                    padding: EdgeInsets.all(10),
                    child: Text(widget.userData['hometown'],
                        style: TextStyle(height: 1, fontSize: 18),
                        textAlign: TextAlign.center))
              ]),
            ),
            Card(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Bio :',
                      style: TextStyle(height: 1, fontSize: 18),
                      textAlign: TextAlign.center)),
              Container(
                width: c_width,
                child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    scrollDirection: Axis.vertical,
                    child: Text(widget.userData['bio'],
                        style: TextStyle(height: 1, fontSize: 18),
                        textAlign: TextAlign.center)),
              ),
            ]))
          ]),
        ));
  }
}
