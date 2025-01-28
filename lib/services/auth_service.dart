import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In for Android and iOS
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Call this method from your UI
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web-specific sign-in logic
        return await _signInWithGoogleWeb();
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile-specific sign-in logic
        return await _signInWithGoogleMobile();
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      rethrow;
    }
  }

  // Sign-in logic for mobile (Android and iOS)
  Future<User?> _signInWithGoogleMobile() async {
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
      return userCredential.user;
    } catch (e) {
      print("Error during Google Sign-In on mobile: $e");
      rethrow;
    }
  }

  // Sign-in logic for web
  Future<User?> _signInWithGoogleWeb() async {
    try {
      // 1. Create a new GoogleAuthProvider instance
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // 2. Add scopes (optional, for additional Google services)
      googleProvider.addScope('email');
      googleProvider.setCustomParameters({
        'prompt': 'select_account', // Forces account selection
      });

      // 3. Sign in to Firebase with the Google provider
      UserCredential userCredential =
          await _auth.signInWithPopup(googleProvider);

      // 4. The user is now signed in
      return userCredential.user;
    } catch (e) {
      print("Error during Google Sign-In on web: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }
}
