/// The person using the app.
class Profile {
  const Profile({required this.name, required this.group});

  /// No name and no group: the profile right after start or Reset data.
  const Profile.empty() : name = '', group = '';

  final String name;
  final String group;

  bool get isEmpty => name.isEmpty;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}
