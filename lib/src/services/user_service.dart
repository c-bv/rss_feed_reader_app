import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(
      {required String uid,
      required String email,
      required String displayName}) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);
      await userDocRef.set({
        'email': email,
        'displayName': displayName,
        'favorites': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
