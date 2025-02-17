import 'dart:convert';

List<Address> addressFromJson(String str) =>
    List<Address>.from(json.decode(str).map((x) => Address.fromJson(x)));

String addressToJson(List<Address> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Address {
  String id;
  String type;
  List<String> id_user;
  String street;
  String city;
  String state;

  DateTime updated;

  Address({
    required this.id,
    required this.type,
    required this.id_user,
    required this.street,
    required this.city,
    required this.state,
    required this.updated,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"] ?? "",
        type: json["type"] ?? "Nomal",
        id_user: (json["id_user"] as List<dynamic>?)
                ?.map((x) => x.toString())
                .toList() ??
            [], // Handle potential null lists
        street: json["street"] ?? "Unknown", // Provide default value
        city: json["city"] ?? "Unknown",
        state: json["state"] ?? "Unknown",
        updated: json["updated"] != null
            ? DateTime.tryParse(json["updated"]) ?? DateTime.now()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "id_user": List<dynamic>.from(id_user.map((x) => x)),
        "street": street,
        "city": city,
        "state": state,
        "updated": updated.toIso8601String(),
      };

  @override
  String toString() {
    return 'Address{ id: $id, type: $type, idUser: $id_user, stress: $street, city: $city, state: $state, updated: $updated}';
  }
}
