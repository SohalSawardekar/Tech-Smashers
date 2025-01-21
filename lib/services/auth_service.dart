import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Call this method from your UI
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Attempt to get the currently authenticated Google user
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // 2. Obtain the auth details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with this credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // 5. The user is now signed in
      User? user = userCredential.user;
      return user;
    } catch (e) {
      // handle errors
      rethrow;
    }
  }

  // For sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
