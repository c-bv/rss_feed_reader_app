import 'package:cloud_firestore/cloud_firestore.dart';

class FeedsService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> postFeed({required String name, required String url}) async {
    try {
      DocumentReference feedDocRef = _firestore.collection('feeds').doc();
      await feedDocRef.set({
        'name': name,
        'url': url,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getFeeds() async {
    try {
      QuerySnapshot feedsSnapshot = await _firestore.collection('feeds').get();
      return feedsSnapshot.docs;
    } catch (e) {
      rethrow;
    }
  }
}
