class Users {
  final int id;
  final String username;
  final String name;
  final String email;

  const Users({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'username': String username,
        'name': String name,
        'email': String email,
      } =>
        Users(
          id: id,
          username: username,
          name: name,
          email: email,
        ),
      _ => const Users(
          id: 0,
          username: '',
          name: '',
          email: '',
        ),
    };
  }
}
