import 'package:flutter/material.dart';
import 'package:project/model/database/pocketbase.dart';
import 'order.dart';

class OrderManager extends ChangeNotifier {
  final DataBase dataBase = DataBase();

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> fetchOrders() async {
    final records = await dataBase.pb.collection('orders').getFullList();
    _orders.clear();
    _orders.addAll(records.map((record) => Order.fromJson(record.data)));
    notifyListeners();
  }

  Future<void> addOrder(Order order) async {
    final record =
        await dataBase.pb.collection('orders').create(body: order.toJson());
    _orders.add(Order.fromJson(record.data));
    notifyListeners();
  }

  Future<void> updateOrder(String id, Order updatedOrder) async {
    await dataBase.pb
        .collection('orders')
        .update(id, body: updatedOrder.toJson());
    final index = _orders.indexWhere((order) => order.id == id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  Future<void> removeOrder(String id) async {
    await dataBase.pb.collection('orders').delete(id);
    _orders.removeWhere((order) => order.id == id);
    notifyListeners();
  }

  List<Order> searchOrders(String query) {
    return _orders
        .where((order) =>
            order.orderCode.contains(query) || order.id.contains(query))
        .toList();
  }

  // Future<List<Order>> getOrdersByUserId(String userId) async {
  //   final records = await dataBase.pb
  //       .collection('orders')
  //       .getFullList(filter: 'userid = "$userId"');
  //   return records.map((record) => Order.fromJson(record.data)).toList();
  // }

  Future<List<Order>> getOrdersByUserId(String userId) async {
    try {
      // Lấy dữ liệu từ PocketBase
      final records = await dataBase.pb.collection('orders').getFullList(
            filter: 'userid = "$userId"', // Lọc theo userid
          );

      // Chuyển đổi JSON thành danh sách Order
      return records.map((record) => Order.fromJson(record.toJson())).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      throw e; // Ném lỗi để xử lý ở nơi gọi hàm
    }
  }
}
