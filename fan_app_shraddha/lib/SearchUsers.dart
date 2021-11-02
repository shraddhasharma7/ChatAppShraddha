import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'ChatScreen.dart';
import 'DatabaseMethods.dart';
import 'SearchDataController.dart';

class SearchUsers extends StatefulWidget {
  final String currentUserName;
  SearchUsers(this.currentUserName);
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final TextEditingController searchController = TextEditingController();
  QuerySnapshot? snapshotData;
  bool isexecuted = false;

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget searchedData() {
      return ListView.builder(
        itemCount: snapshotData!.docs.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              var name = [snapshotData!.docs[index].data()['username']][0];
              var chatRoomId =
                  getChatRoomIdByUsernames(name, widget.currentUserName);
              var chatRoomId1 = getChatRoomIdByUsernames(widget.currentUserName,
                  snapshotData!.docs[index].data()['username']);
              Map<String, dynamic> chatRoomInfoMap = {
                "users": [name, widget.currentUserName]
              };

              Map<String, dynamic> chatRoomInfoMap1 = {
                "users": [name, widget.currentUserName]
              };

              var chatroom = "";
              DatabaseMethods()
                  .checkWhetherChatRoomExists(chatRoomId)
                  .then((value) {
                if (value) {
                  chatroom = chatRoomId;
                } else {
                  chatroom = chatRoomId1;
                  DatabaseMethods().createChatRoom(chatroom, chatRoomInfoMap1);
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            name, widget.currentUserName, chatroom)));
              });
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    snapshotData!.docs[index].data()['profile_pic']),
              ),
              title: Text(
                snapshotData!.docs[index].data()['username'],
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
        backgroundColor: Colors.amberAccent,
        appBar: AppBar(
          actions: [
            GetBuilder<SearchDataController>(
                init: SearchDataController(),
                builder: (val) {
                  return IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      val.queryData(searchController.text).then((value) {
                        snapshotData = value;
                        setState(() {
                          isexecuted = true;
                        });
                      });
                    },
                  );
                })
          ],
          title: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                hintText: "search users",
                hintStyle: TextStyle(color: Colors.white)),
            controller: searchController,
          ),
        ),
        body: isexecuted
            ? searchedData()
            : Container(
                child: Center(
                  child: Text(
                    'search any user',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0),
                  ),
                ),
              ));
  }
}
