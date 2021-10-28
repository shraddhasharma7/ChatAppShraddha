import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String profilePic, String bio,
      String hometown, String age) async {
    var newFormat = DateFormat("yy-MM-dd");
    String updatedDt = newFormat.format(new DateTime.now());
    print(updatedDt);

    return await usersCollection.doc(uid).set({
      'username': name,
      'profile_pic': profilePic,
      'bio': bio,
      'hometown': hometown,
      'age': age,
      'date': updatedDt
    });
  }
}
