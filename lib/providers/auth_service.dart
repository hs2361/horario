import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthState { SignedIn, NotVerified, SignedUp, SignedOut }

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  /// Changed to idTokenChanges as it updates depending on more cases.
  Stream<User?> get authStateChanges => _firebaseAuth.idTokenChanges();

  String? get displayName => FirebaseAuth.instance.currentUser?.displayName;
  String? get photoUrl => FirebaseAuth.instance.currentUser?.photoURL;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    print("sign in with google");
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>['email'],
    );

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<AuthState> emailSignIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        return AuthState.SignedIn;
      } else {
        await user?.sendEmailVerification();
        return AuthState.NotVerified;
      }
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<AuthState> emailSignUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      user?.updateProfile(displayName: name);
      return AuthState.SignedUp;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<bool> get isGoogleUser async {
    return await GoogleSignIn().isSignedIn();
  }

  String get userName {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? user.displayName ?? 'Student' : 'Student';
  }

  Future<void> updateName(String name) async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.updateProfile(displayName: name);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
}
