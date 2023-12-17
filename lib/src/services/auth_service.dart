import 'package:firebase_auth/firebase_auth.dart';
import 'package:rss_feed_reader_app/src/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  bool get isUserLoggedIn => _auth.currentUser != null;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<User?> signIn({required String email, required String password}) async {
    User? user;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!isEmailVerified) {
        throw FirebaseAuthException(code: 'email-not-verified');
      }
      user = userCredential.user;

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> register(
      {required String email,
      required String password,
      required String displayName}) async {
    User? user;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(displayName);
      print('1');
      await userCredential.user!.sendEmailVerification();
      print('2');

      await _userService.createUserDocument(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
      );
      print('3');

      user = userCredential.user;

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> refreshUser(User user) async {
    await user.reload();
    User? refreshedUser = _auth.currentUser;

    return refreshedUser;
  }
}
