// import 'dart:convert';

// List<OrderItem> orderItemFromJson(String str) =>
//     List<OrderItem>.from(json.decode(str).map((x) => OrderItem.fromJson(x)));

// String orderItemToJson(List<OrderItem> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class OrderItem {
//   String collectionId;
//   String collectionName;
//   String id;
//   String orderId;
//   List<String> productId;
//   DateTime created;
//   DateTime updated;

//   OrderItem({
//     required this.collectionId,
//     required this.collectionName,
//     required this.id,
//     required this.orderId,
//     required this.productId,
//     required this.created,
//     required this.updated,
//   });

//   factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
//         collectionId: json["collectionId"] ?? "", // Default empty string
//         collectionName: json["collectionName"] ?? "",
//         id: json["id"] ?? "",
//         orderId: json["order_id"] ?? "",
//         productId: (json["product_id"] as List<dynamic>?)
//                 ?.map((x) => x.toString())
//                 .toList() ??
//             [], // Ensures it's always a List<String>
//         created: json["created"] != null
//             ? DateTime.tryParse(json["created"]) ?? DateTime.now()
//             : DateTime.now(), // Default to current time if null or invalid
//         updated: json["updated"] != null
//             ? DateTime.tryParse(json["updated"]) ?? DateTime.now()
//             : DateTime.now(),
//       );

//   Map<String, dynamic> toJson() => {
//         "collectionId": collectionId,
//         "collectionName": collectionName,
//         "id": id,
//         "order_id": orderId,
//         "product_id":
//             productId, // No need to use `List<dynamic>.from()`, it's already a List<String>
//         "created": created.toIso8601String(),
//         "updated": updated.toIso8601String(),
//       };
//   @override
//   String toString() {
//     return 'OrderItem{collectionId: $collectionId, collectionName: $collectionName, id: $id, orderId: $orderId, productId: $productId, created: $created, updated: $updated}';
//   }
// }
import 'dart:convert';

List<OrderItem> orderItemFromJson(String str) =>
    List<OrderItem>.from(json.decode(str).map((x) => OrderItem.fromJson(x)));

String orderItemToJson(List<OrderItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderItem {
  String collectionId;
  String collectionName;
  String id;
  String orderId;
  List<Map<String, dynamic>> items; // Thay productId bằng items
  DateTime created;
  DateTime updated;

  OrderItem({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.orderId,
    required this.items,
    required this.created,
    required this.updated,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Xử lý trường items (JSON)
    List<Map<String, dynamic>> itemsList = [];
    if (json["items"] is List) {
      itemsList = (json["items"] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } else if (json["items"] is String && json["items"] != "JSON") {
      // Xử lý trường hợp items là chuỗi JSON (nếu cần)
      try {
        itemsList = (jsonDecode(json["items"]) as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } catch (e) {
        print('Error parsing items JSON: $e');
      }
    }

    return OrderItem(
      collectionId: json["collectionId"] ?? "",
      collectionName: json["collectionName"] ?? "",
      id: json["id"] ?? "",
      orderId: json["order_id"] ?? "",
      items: itemsList,
      created: json["created"] != null
          ? DateTime.tryParse(json["created"]) ?? DateTime.now()
          : DateTime.now(),
      updated: json["updated"] != null
          ? DateTime.tryParse(json["updated"]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "order_id": orderId,
        "items": items,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  @override
  String toString() {
    return 'OrderItem{collectionId: $collectionId, collectionName: $collectionName, id: $id, orderId: $orderId, items: $items, created: $created, updated: $updated}';
  }
}
