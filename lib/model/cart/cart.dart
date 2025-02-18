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
  List<String> productId;
  DateTime created;
  DateTime updated;

  Cart({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.userId,
    required this.productId,
    required this.created,
    required this.updated,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"] ?? " ",
        userId: json["user_id"] ?? "",
        productId: List<String>.from(json["product_id"].map((x) => x)),
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "user_id": userId,
        "product_id": List<dynamic>.from(productId.map((x) => x)),
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };
  @override
  String toString() {
    return 'Cart{collectionId: $collectionId, collectionName: $collectionName, id: $id, userId: $userId, productId: $productId, created: $created, updated: $updated}';
  }
}
