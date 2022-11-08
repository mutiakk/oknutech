class Profile {
  Profile({
    this.email,
    this.firstName,
    this.lastName,
  });

  String? email;
  String? firstName;
  String? lastName;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    email: json["email"],
    firstName: json["first_name"],
    lastName: json["last_name"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
  };
}