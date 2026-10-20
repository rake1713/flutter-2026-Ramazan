class Profile {
  final String name;
  final String group;

  const Profile({required this.name, required this.group});

  const Profile.empty() : name = '', group = '';

  bool get isEmpty => name.isEmpty;

  Profile copyWith({String? name, String? group}) {
    return Profile(name: name ?? this.name, group: group ?? this.group);
  }
}
