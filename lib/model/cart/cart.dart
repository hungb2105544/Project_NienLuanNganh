// import 'dart:convert';

// List<Cart> cartFromJson(String str) =>
//     List<Cart>.from(json.decode(str).map((x) => Cart.fromJson(x)));

// String cartToJson(List<Cart> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class Cart {
//   String collectionId;
//   String collectionName;
//   String id;
//   String userId;
//   List<String> productId;
//   DateTime created;
//   DateTime updated;

//   Cart({
//     required this.collectionId,
//     required this.collectionName,
//     required this.id,
//     required this.userId,
//     required this.productId,
//     required this.created,
//     required this.updated,
//   });

//   factory Cart.fromJson(Map<String, dynamic> json) => Cart(
//         collectionId: json["collectionId"],
//         collectionName: json["collectionName"],
//         id: json["id"] ?? " ",
//         userId: json["user_id"] ?? "",
//         productId: List<String>.from(json["product_id"].map((x) => x)),
//         created: DateTime.parse(json["created"]),
//         updated: DateTime.parse(json["updated"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "collectionId": collectionId,
//         "collectionName": collectionName,
//         "id": id,
//         "user_id": userId,
//         "product_id": List<dynamic>.from(productId.map((x) => x)),
//         "created": created.toIso8601String(),
//         "updated": updated.toIso8601String(),
//       };

//   Cart copyWith({
//     String? collectionId,
//     String? collectionName,
//     String? id,
//     String? userId,
//     List<String>? productId,
//     DateTime? created,
//     DateTime? updated,
//   }) {
//     return Cart(
//       collectionId: collectionId ?? this.collectionId,
//       collectionName: collectionName ?? this.collectionName,
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       productId: productId ?? this.productId,
//       created: created ?? this.created,
//       updated: updated ?? this.updated,
//     );
//   }

//   @override
//   String toString() {
//     return 'Cart{collectionId: $collectionId, collectionName: $collectionName, id: $id, userId: $userId, productId: $productId, created: $created, updated: $updated}';
//   }
// }
import 'dart:convert';

List<Cart> cartFromJson(String str) =>
    List<Cart>.from(json.decode(str).map((x) => Cart.fromJson(x)));

String cartToJson(List<Cart> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Cart {
  String collectionId;
  String collectionName;
  String id;
  String userId;
  List<Map<String, dynamic>> items; // Thay productId bằng items
  DateTime created;
  DateTime updated;

  Cart({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.userId,
    required this.items,
    required this.created,
    required this.updated,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        collectionId: json["collectionId"] ?? "",
        collectionName: json["collectionName"] ?? "",
        id: json["id"] ?? "",
        userId: json["user_id"] ?? "",
        items: json["items"] != null
            ? (json["items"] as List<dynamic>)
                .map((x) => Map<String, dynamic>.from(x as Map))
                .toList()
            : [],
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
        "user_id": userId,
        "items": items,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  Cart copyWith({
    String? collectionId,
    String? collectionName,
    String? id,
    String? userId,
    List<Map<String, dynamic>>? items,
    DateTime? created,
    DateTime? updated,
  }) {
    return Cart(
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'Cart{collectionId: $collectionId, collectionName: $collectionName, id: $id, userId: $userId, items: $items, created: $created, updated: $updated}';
  }
}
