import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Use a final instance to ensure consistency
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    print('DEBUG_AUTH: signInWithGoogle started');
    try {
      print('DEBUG_AUTH: Showing Google picker');
      // Ensure we are calling the correct method on the instance
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      print('DEBUG_AUTH: googleUser = $googleUser');
      if (googleUser == null) {
        print('DEBUG_AUTH: User cancelled sign-in');
        return null;
      }

      print('DEBUG_AUTH: Getting auth tokens');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Correctly access tokens for Firebase credential
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      print('DEBUG_AUTH: tokens = ${accessToken != null ? 'access_ok' : 'access_null'}, ${idToken != null ? 'id_ok' : 'id_null'}');

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      print('DEBUG_AUTH: Signing in to Firebase');
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      print('DEBUG_AUTH: Firebase user = ${user?.uid}');

      if (user != null) {
        print('DEBUG_AUTH: Writing user doc to Firestore');
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('DEBUG_AUTH: Firestore write complete');
      }

      notifyListeners();
      print('DEBUG_AUTH: Sign-in success');
      return userCredential;
    } catch (e, stack) {
      print('DEBUG_AUTH: Sign-in failed: $e');
      print('DEBUG_AUTH: Stack: $stack');
      rethrow;
    }
  }

  Future<String?> getIdToken() async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      print('DEBUG_AUTH: getIdToken returned: ${token != null ? 'valid' : 'null'}');
      return token;
    } catch (e) {
      print('DEBUG_AUTH: getIdToken error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }
}
