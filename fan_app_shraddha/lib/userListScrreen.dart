import 'package:fan_app_shraddha/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'ChatScreen.dart';
import 'DatabaseMethods.dart';
import 'Profile.dart';

class userListScrreen extends StatefulWidget {
  @override
  _userListScrreenState createState() => _userListScrreenState();
}

class _userListScrreenState extends State<userListScrreen> {
  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User List Screen"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('username', descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            snapshot.data!.docs;
          }
          var usee_list = snapshot.data!.docs;

          return Row(children: [
            Expanded(
              child: ListView.builder(
                itemCount: usee_list.length,
                itemBuilder: (context, index) {
                  var product = usee_list[index]['profile_pic'];
                  return GestureDetector(
                    onTap: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(
                                  userData: snapshot.data!.docs[index])));
                    }),
                    child: Card(
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.all(15.0),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                                //child: Card(
                                child: Row(
                                    //Icon(_icons[index], color: Colors.grey,),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  CachedNetworkImage(
                                      width: 50,
                                      height: 50,
                                      imageUrl: usee_list[index]
                                          ['profile_pic']),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    usee_list[index]['username'],
                                    //style: TextStyle(color: _colors[index]),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    usee_list[index]['date'].toString(),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                ])
                                //)
                                )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ]);
        },
      ),
    );
  }
}
