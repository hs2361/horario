import 'package:horario/models/user.dart';

class AuthUser extends User {
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
