import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchDataController extends GetxController {
  /// new one for search just for testing

  Future getData(String collection) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot =
        await firebaseFirestore.collection(collection).get();
    return snapshot.docs;
  }

  Future queryData(String queryString) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: queryString)
        .get();
  }
}
