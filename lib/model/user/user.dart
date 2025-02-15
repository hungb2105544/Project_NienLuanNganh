class User {
  String id;
  String email;
  String name;
  // String avatar;
  String fullname;
  String phone;
  DateTime created;
  DateTime updated;

  User({
    required this.id,
    required this.email,
    required this.name,
    // required this.avatar,
    required this.fullname,
    required this.phone,
    required this.created,
    required this.updated,
  });
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] ?? "",
        email: json["email"] ?? "",
        name: json["name"] ?? "No Name",
        // avatar: json["avatar"] ?? "",
        fullname: json["fullname"] ?? "No Full Name",
        phone: json["phone"] ?? "",
        created: json["created"] != null
            ? DateTime.parse(json["created"])
            : DateTime.now(),
        updated: json["updated"] != null
            ? DateTime.parse(json["updated"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "name": name,
        // "avatar": avatar,
        "fullname": fullname,
        "phone": phone,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  @override
  String toString() {
    return 'User( id: $id, email: $email, name: $name, fullname: $fullname, phone: $phone, created: $created, updated: $updated)';
  }
}
