import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String? id;
  String? name;
  String? biography;
  DateTime? birthday;

  Profile({this.id, this.name, this.biography, this.birthday});

  Map<String, dynamic> toMap() =>
      {"id": id, "name": name, "biography": biography, "birthday": birthday};

  Profile.from(DocumentSnapshot snapshot) {
    final Map<String, dynamic>? map = snapshot.data();
    id = map?["id"] as String?;
    name = map?["name"] as String?;
    biography = map?["biography"] as String?;
    birthday = (map?["birthday"] as Timestamp?)?.toDate();
  }

  Profile clone() => Profile(
        id: id,
        name: name,
        biography: biography,
        birthday: birthday,
      );
}
