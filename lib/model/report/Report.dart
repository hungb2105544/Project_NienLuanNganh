import 'dart:convert';

// Helper function to convert JSON string to List<Report>
List<Report> reportFromJson(String str) =>
    List<Report>.from(json.decode(str).map((x) => Report.fromJson(x)));

// Helper function to convert List<Report> to JSON string
String reportToJson(List<Report> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Report class definition
class Report {
  String collectionId;
  String collectionName;
  String id;
  String title;
  String content;
  String reply;
  String userId;
  DateTime created;
  DateTime updated;

  // Constructor
  Report({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.title,
    required this.content,
    required this.reply,
    required this.userId,
    required this.created,
    required this.updated,
  });

  // Factory method to create a Report object from JSON
  factory Report.fromJson(Map<String, dynamic> json) => Report(
        collectionId: json["collectionId"] ?? '',
        collectionName: json["collectionName"] ?? '',
        id: json["id"] ?? '',
        title: json["title"] ?? '',
        content: json["content"] ?? '',
        reply: json["reply"] ?? '',
        userId: json["user_id"] ?? '',
        created: DateTime.tryParse(json["created"] ?? '') ?? DateTime.now(),
        updated: DateTime.tryParse(json["updated"] ?? '') ?? DateTime.now(),
      );

  // Method to convert a Report object to JSON
  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "title": title,
        "content": content,
        "reply": reply,
        "user_id": userId,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  // Override toString() for easy debugging
  @override
  String toString() {
    return 'Report('
        'collectionId: $collectionId, '
        'collectionName: $collectionName, '
        'id: $id, '
        'title: $title, '
        'content: $content, '
        'reply: $reply, '
        'userId: $userId, '
        'created: $created, '
        'updated: $updated)';
  }
}
