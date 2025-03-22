import 'dart:convert';

List<PromotionUser> promotionUserFromJson(String str) =>
    List<PromotionUser>.from(json.decode(str).map(PromotionUser.fromJson));

String promotionUserToJson(List<PromotionUser> data) =>
    json.encode(data.map((x) => x.toJson()).toList());

class PromotionUser {
  final String id;
  final String userId;
  final String promotionId;
  final DateTime savedAt;
  final bool isUsed;
  final DateTime created;
  final DateTime updated;

  const PromotionUser({
    required this.id,
    required this.userId,
    required this.promotionId,
    required this.savedAt,
    required this.isUsed,
    required this.created,
    required this.updated,
  });

  factory PromotionUser.fromJson(Map<String, dynamic> json) => PromotionUser(
        id: json["id"],
        userId: json["user_id"],
        promotionId: json["promotion_id"],
        savedAt: DateTime.parse(json["saved_at"]),
        isUsed: json["is_used"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "promotion_id": promotionId,
        "saved_at": savedAt.toIso8601String(),
        "is_used": isUsed,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };
}
