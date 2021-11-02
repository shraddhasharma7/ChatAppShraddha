import 'package:fan_app_shraddha/Start.dart';
import 'package:fan_app_shraddha/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer';
import 'package:uuid/uuid.dart';
import 'dart:io' as io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fan_app_shraddha/profile.dart';
import 'ChatScreen.dart';
import 'DatabaseMethods.dart';
import 'SearchUsers.dart';
import 'userListScrreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  bool isloggedin = false;

  bool isSearching = false;

  TextEditingController searchUserNameEditingController =
      TextEditingController();

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      } else {
        getUserData(user.uid).then((QuerySnapshot docs) {
          if (docs.docs.isNotEmpty) {
            var test = docs.docs[0].data();

            if (test['role'] == 'admin') hideWidget();
          }
        });
      }
    });
  }

  getUserData(String userID) {
    print('user id is');
    print(userID);
    return FirebaseFirestore.instance
        .collection('userList')
        .where('user id', isEqualTo: userID)
        .get();
  }

  bool _canShowButton = false;

  void hideWidget() {
    setState(() {
      _canShowButton = !_canShowButton;
    });
  }

  getUser() async {
    User firebaseUser = _auth.currentUser;
    await firebaseUser.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
    onScreenLoaded();
  }

  TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Message'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Add your post here.."),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                child: Text('POST MESSAGE'),
                onPressed: () {
                  FirebaseFirestore.instance.collection('postList').add({
                    'message': valueText,
                    'date': new DateTime.now(),
                    'messageId': Uuid().v4()
                  });
                  setState(() {
                    codeDialog = valueText;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  late String codeDialog;
  late String valueText;

  showSignoutAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(title: Text('SIGN OUT'), actions: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  signOut();
                },
                child: Text('OK'))
          ]);
        });
  }

  ///////
  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chatrooms")
          .orderBy("lastMessageSendTs", descending: true)
          .where("users", arrayContains: this.user.displayName)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return snapshot.hasData
            ? Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data!.docs[index];
                      return ChatRoomListTile(
                          ds["lastMessage"], ds.id, this.user.displayName);
                    }),
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getChatRooms() async {
    chatRoomsList();
    setState(() {});
  }

  onScreenLoaded() async {
    getChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    //final FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);
    return Scaffold(
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
                onPressed: showSignoutAlert,
                icon: Icon(Icons.first_page, size: 30)),
            Text(user.displayName, style: TextStyle(fontSize: 18)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SearchUsers(this.user.displayName)));
                  //Navigator.of(context).push(MaterialPageRoute(
                  // builder: (context) => userListScrreen()));
                },
                icon: Icon(Icons.search, size: 30)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => userListScrreen()));
                  //Navigator.of(context).push(MaterialPageRoute(
                  // builder: (context) => userListScrreen()));
                },
                icon: Icon(Icons.add, size: 30))
          ],
        )),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  isSearching
                      ? GestureDetector(
                          onTap: () {
                            isSearching = false;
                            searchUserNameEditingController.text = '';
                            setState(() {});
                          },
                          child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_back)),
                        )
                      : Container(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [],
                      ),
                    ),
                  ),
                ],
              ),
              chatRoomsList()
            ],
          ),
        ));
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    // print(
    //     "something bla bla ${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["username"]}  ${querySnapshot.docs[0]["profile_pic"]}");
    name = "${querySnapshot.docs[0]["username"]}";
    profilePicUrl = "${querySnapshot.docs[0]["profile_pic"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(name, widget.myUsername);
        var chatRoomId1 = getChatRoomIdByUsernames(widget.myUsername, name);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [name, widget.myUsername]
        };

        Map<String, dynamic> chatRoomInfoMap1 = {
          "users": [name, widget.myUsername]
        };

        var chatroom = "";
        DatabaseMethods().checkWhetherChatRoomExists(chatRoomId).then((value) {
          if (value) {
            chatroom = chatRoomId;
          } else {
            chatroom = chatRoomId1;
            DatabaseMethods().createChatRoom(chatroom, chatRoomInfoMap1);
          }
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(name, widget.myUsername, chatroom)))
              .then((value) => setState(() {}));
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => ChatScreen(username, name)));
        });
      },
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30.0,
                      child: ClipOval(
                          child: CachedNetworkImage(
                              width: 100,
                              height: 100,
                              imageUrl: profilePicUrl)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.0),
                                ),
                                Text(
                                  name,
                                  style: TextStyle(color: Colors.black45),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                widget.lastMessage,
                                style: TextStyle(
                                    color: Colors.black45, fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(),
            ],
          )),
    );
  }
}
