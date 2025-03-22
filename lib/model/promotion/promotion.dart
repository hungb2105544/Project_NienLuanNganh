import 'dart:convert';

List<Promotion> promotionFromJson(String str) =>
    List<Promotion>.from(json.decode(str).map((x) => Promotion.fromJson(x)));

String promotionToJson(List<Promotion> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Promotion {
  final String id;
  final String code;
  final String description;
  final String discountType;
  final int discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final int minOrderValue;
  final int maxUsage;
  final bool active;

  const Promotion({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.minOrderValue,
    required this.maxUsage,
    required this.active,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json["id"] as String,
        code: json["code"] as String,
        description: json["description"],
        discountType: json["discount_type"] as String,
        discountValue: json["discount_value"] as int,
        startDate: DateTime.parse(json["start_date"] as String),
        endDate: DateTime.parse(json["end_date"] as String),
        minOrderValue: json["min_order_value"] as int,
        maxUsage: json["max_usage"] as int,
        active: json["active"] as bool,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "description": description,
        "discount_type": discountType,
        "discount_value": discountValue,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "min_order_value": minOrderValue,
        "max_usage": maxUsage,
        "active": active,
      };

  @override
  String toString() =>
      'Promotion(id: $id, code: $code, active: $active, discount: $discountValue)';
}
