import 'package:project/model/order/order_item.dart';
import 'package:project/model/database/pocketbase.dart';

class OrderItemManager {
  final DataBase dataBase = DataBase();

  final List<OrderItem> _orderItems = [];

  List<OrderItem> get orderItems => List.unmodifiable(_orderItems);

  /// Fetch all order items from the database
  Future<void> fetchOrderItems() async {
    try {
      final records = await dataBase.pb.collection('order_item').getFullList();
      _orderItems.clear();
      _orderItems
          .addAll(records.map((record) => OrderItem.fromJson(record.data)));
    } catch (e) {
      print('Error fetching order items: $e');
    }
  }

  /// Fetch a single order item by ID
  Future<OrderItem?> getOneOrderItem(String id) async {
    try {
      final record = await dataBase.pb.collection('order_item').getList(
            filter: 'order_id = "$id"',
          );
      return OrderItem.fromJson(record.items.first.data);
    } catch (e) {
      print('Error fetching order item with ID $id: $e');
      return null; // Return null to avoid crashes
    }
  }

  /// Add a new order item to the database
  Future<void> addOrderItem(OrderItem orderItem) async {
    try {
      final record = await dataBase.pb
          .collection('order_item')
          .create(body: orderItem.toJson());
      _orderItems.add(OrderItem.fromJson(record.data));
    } catch (e) {
      print('Error adding order item: $e');
    }
  }

  /// Delete an order item by ID
  Future<void> deleteOrderItem(String id) async {
    try {
      await dataBase.pb.collection('order_item').delete(id);
      _orderItems.removeWhere((item) => item.id == id);
    } catch (e) {
      print('Error deleting order item with ID $id: $e');
    }
  }

  /// Update an existing order item
  Future<void> updateOrderItem(OrderItem orderItem) async {
    try {
      final record = await dataBase.pb
          .collection('order_item')
          .update(orderItem.id, body: orderItem.toJson());
      int index = _orderItems.indexWhere((item) => item.id == orderItem.id);
      if (index != -1) {
        _orderItems[index] = OrderItem.fromJson(record.data);
      }
    } catch (e) {
      print('Error updating order item with ID ${orderItem.id}: $e');
    }
  }

  Future<OrderItem?> getOrderItemByOrderID(String id) async {
    try {
      final record =
          await dataBase.pb.collection('order_item').getOne('order_id="$id"');
      return OrderItem.fromJson(record.data);
    } catch (e) {
      print('Error fetching order item with order ID $id: $e');
      return null;
    }
  }
}
