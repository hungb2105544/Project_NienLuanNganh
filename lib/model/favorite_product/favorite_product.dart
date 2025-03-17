import 'dart:convert';

// Hàm chuyển đổi JSON
List<FavoriteProduct> favoriteProductFromJson(String str) {
  final jsonData = json.decode(str);
  if (jsonData is List) {
    return jsonData.map((x) => FavoriteProduct.fromJson(x)).toList();
  }
  return [];
}

String FavoriteProductToJson(List<FavoriteProduct> data) =>
    json.encode(data.map((x) => x.toJson()).toList());

class FavoriteProduct {
  final String id;
  final String userId;
  final List<String> productIds;
  final DateTime created;
  final DateTime updated;

  FavoriteProduct({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.created,
    required this.updated,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) =>
      FavoriteProduct(
        id: json['id'] ?? '',
        userId: json['id_users'] ?? '',
        productIds: json['id_products'] != null
            ? List<String>.from(json['id_products'])
            : [],
        created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
        updated: DateTime.tryParse(json['updated'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_users': userId,
        'id_products': productIds,
        'created': created.toIso8601String(),
        'updated': updated.toIso8601String(),
      };
}
