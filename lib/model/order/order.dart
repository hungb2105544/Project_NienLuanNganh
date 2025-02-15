import 'dart:convert';

List<Order> orderFromJson(String str) =>
    List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

String orderToJson(List<Order> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Order {
  String collectionId;
  String collectionName;
  String id;
  String userid;
  String orderCode;
  DateTime orderDate;
  int totalNumber;
  String status;
  String paymentMethod;
  String addressId;
  DateTime created;
  DateTime updated;

  Order({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.userid,
    required this.orderCode,
    required this.orderDate,
    required this.totalNumber,
    required this.status,
    required this.paymentMethod,
    required this.addressId,
    required this.created,
    required this.updated,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        userid: json["userid"],
        orderCode: json["order_code"],
        orderDate: DateTime.parse(json["order_date"]),
        totalNumber: json["total_number"],
        status: json["status"],
        paymentMethod: json["payment_method"],
        addressId: json["address_id"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "userid": userid,
        "order_code": orderCode,
        "order_date": orderDate.toIso8601String(),
        "total_number": totalNumber,
        "status": status,
        "payment_method": paymentMethod,
        "address_id": addressId,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  @override
  String toString() {
    return 'Order{collectionId: $collectionId, collectionName: $collectionName, id: $id, userid: $userid, orderCode: $orderCode, orderDate: $orderDate, totalNumber: $totalNumber, status: $status, paymentMethod: $paymentMethod, addressId: $addressId, created: $created, updated: $updated}';
  }
}
