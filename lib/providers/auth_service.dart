import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:horario/models/auth_user.dart';
import 'package:horario/models/profile.dart';

// ignore: constant_identifier_names
enum AuthState { SignedIn, NotVerified, SignedUp, SignedOut }

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  /// Changed to idTokenChanges as it updates depending on more cases.
  Stream<User?> get authStateChanges => _firebaseAuth.idTokenChanges();
  String? groupId;
  String? get displayName => FirebaseAuth.instance.currentUser?.displayName;
  String? get photoUrl => FirebaseAuth.instance.currentUser?.photoURL;
  String? get email => FirebaseAuth.instance.currentUser?.email;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;
  String? get getGroupId => groupId;
  Future<String?> get token async =>
      await FirebaseAuth.instance.currentUser?.getIdToken();
  Profile? profile;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<AuthState> emailSignIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        return AuthState.SignedIn;
      } else {
        await user?.sendEmailVerification();
        return AuthState.NotVerified;
      }
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<AuthState> emailSignUp(AuthUser authUser) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: authUser.email ?? "",
        password: authUser.password ?? "",
      );
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      //We should start moving away from FirebaseAuth profile to Firestore
      user?.updateDisplayName(authUser.name);
      updateProfile(authUser);

      return AuthState.SignedUp;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userReference =
        firestore.collection('users').doc(userId);

    try {
      await userReference.set(profile.toMap());
    } on Exception {
      rethrow;
    }
    this.profile = profile;
    return profile;
  }

  String get userName {
    if (profile != null && profile!.name != null) {
      return profile!.name!;
    }
    //Left for backwards compability
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? user.displayName ?? 'Student' : 'Student';
  }

  Future<void> updateName(String name) async {
    final User? user = FirebaseAuth.instance.currentUser;
    await user?.updateDisplayName(name);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> checkGroupID() async {
    //Check if user is a part of any group and if he isnt then store group_id as empty string
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference groups = firestore.collection('groups');
    final String? currUserEmail = FirebaseAuth.instance.currentUser?.email;

    final firestoreGroups =
        (await groups.where('members', arrayContains: currUserEmail).get())
            .docs;

    for (final QueryDocumentSnapshot doc in firestoreGroups) {
      groupId = doc.id;
      final FirebaseMessaging _fcm = FirebaseMessaging.instance;
      _fcm.subscribeToTopic(groupId!);
    }
  }

  Future<Profile> fetchProfile() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userReference =
        firestore.collection('users').doc(userId);

    try {
      profile = await userReference.get().then((value) => Profile.from(value));
    } on Exception {
      rethrow;
    }

    if (profile!.name == null) {
      profile!.name = userName;
    }
    return profile!.clone();
  }
}
