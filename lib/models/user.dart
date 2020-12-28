class User {
  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.salt,
    this.accessToken,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> data) => data == null
      ? null
      : User(
          id: data['_id'] as String,
          firstName: data['first_name'] as String,
          lastName: data['last_name'] as String,
          email: data['email'] as String,
          password: data['password'] as String,
          salt: data['salt'] as String,
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String salt;
  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'salt': salt,
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
}
