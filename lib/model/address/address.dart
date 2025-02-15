import 'dart:convert';

List<Address> addressFromJson(String str) =>
    List<Address>.from(json.decode(str).map((x) => Address.fromJson(x)));

String addressToJson(List<Address> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Address {
  String collectionId;
  String collectionName;
  String id;
  List<String> idUser;
  String street;
  String city;
  String state;
  DateTime created;
  DateTime updated;

  Address({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.idUser,
    required this.street,
    required this.city,
    required this.state,
    required this.created,
    required this.updated,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        collectionId: json["collectionId"] ?? "",
        collectionName: json["collectionName"] ?? "",
        id: json["id"] ?? "", // Ensure id is never null
        idUser: (json["id_user"] as List<dynamic>?)
                ?.map((x) => x.toString())
                .toList() ??
            [], // Handle potential null lists
        street: json["street"] ?? "Unknown", // Provide default value
        city: json["city"] ?? "Unknown",
        state: json["state"] ?? "Unknown",
        created: json["created"] != null
            ? DateTime.tryParse(json["created"]) ?? DateTime.now()
            : DateTime.now(),
        updated: json["updated"] != null
            ? DateTime.tryParse(json["updated"]) ?? DateTime.now()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "id_user": List<dynamic>.from(idUser.map((x) => x)),
        "street": street,
        "city": city,
        "state": state,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  @override
  String toString() {
    return 'Address{collectionId: $collectionId, collectionName: $collectionName, id: $id, idUser: $idUser, stress: $street, city: $city, state: $state, created: $created, updated: $updated}';
  }
}
