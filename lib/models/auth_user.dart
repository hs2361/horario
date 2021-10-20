import 'package:horario/models/profile.dart';

class AuthUser extends Profile {
  String? email;
  String? password;

  Map<String, String> getSignUpCredentials() {
    return {
      "name": name ?? "",
      "password": password ?? "",
      "email": email ?? ""
    };
  }
}
