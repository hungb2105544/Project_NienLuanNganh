class Category {
  String collectionId;
  String collectionName;
  String id;
  String name;
  String description;
  String image;
  DateTime created;
  DateTime updated;

  Category({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.created,
    required this.updated,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        name: json["name"],
        description: json["description"],
        image: json["image"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };
}
