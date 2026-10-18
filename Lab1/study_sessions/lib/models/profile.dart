/// The person using the app.
class Profile {
  final String name;
  final String group;

  const Profile({required this.name, required this.group});

  /// No name and no group: the profile at start and after Reset data.
  const Profile.empty() : name = '', group = '';

  bool get isEmpty => name.isEmpty;

  Profile copyWith({String? name, String? group}) {
    return Profile(name: name ?? this.name, group: group ?? this.group);
  }
}
