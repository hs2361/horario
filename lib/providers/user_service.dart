import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:horario/models/user.dart';

import 'auth_service.dart';

class UserService with ChangeNotifier {
  late User _user;

  User get user => _user.clone();

  UserService() {
    _user = User();
  }

  Future<void> updateUser(User user) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userReference =
        firestore.collection('users').doc(user.id);

    try {
      await userReference.set(user.toMap());
    } on Exception {
      rethrow;
    }
    _user = user;
    notifyListeners();
  }

  Future<User> loadUser(AuthService authService) async {
    final String? id = authService.userId;
    if (id == null) {
      throw FirebaseAuthException(code: "User has not sign in");
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userReference =
        firestore.collection('users').doc(id);

    try {
      _user = await userReference.get().then((value) => User.from(value));
      print("User loaded: ${_user.toMap()}");
    } on Exception {
      rethrow;
    }
    return _user.clone();
  }
}
