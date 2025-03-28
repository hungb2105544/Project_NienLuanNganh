// // import 'package:project/model/order/order_item.dart';
// // import 'package:project/model/database/pocketbase.dart';

// // class OrderItemManager {
// //   final DataBase dataBase = DataBase();

// //   final List<OrderItem> _orderItems = [];

// //   List<OrderItem> get orderItems => List.unmodifiable(_orderItems);

// //   /// Fetch all order items from the database
// //   Future<void> fetchOrderItems() async {
// //     try {
// //       final records = await dataBase.pb.collection('order_item').getFullList();
// //       _orderItems.clear();
// //       _orderItems
// //           .addAll(records.map((record) => OrderItem.fromJson(record.data)));
// //     } catch (e) {
// //       print('Error fetching order items: $e');
// //     }
// //   }

// //   /// Fetch a single order item by ID
// //   Future<OrderItem?> getOneOrderItem(String id) async {
// //     try {
// //       final record = await dataBase.pb.collection('order_item').getList(
// //             filter: 'order_id = "$id"',
// //           );
// //       return OrderItem.fromJson(record.items.first.data);
// //     } catch (e) {
// //       print('Error fetching order item with ID $id: $e');
// //       return null; // Return null to avoid crashes
// //     }
// //   }

// //   /// Add a new order item to the database
// //   Future<void> addOrderItem(OrderItem orderItem) async {
// //     try {
// //       final record = await dataBase.pb
// //           .collection('order_item')
// //           .create(body: orderItem.toJson());
// //       _orderItems.add(OrderItem.fromJson(record.data));
// //     } catch (e) {
// //       print('Error adding order item: $e');
// //     }
// //   }

// //   /// Delete an order item by ID
// //   Future<void> deleteOrderItem(String id) async {
// //     try {
// //       await dataBase.pb.collection('order_item').delete(id);
// //       _orderItems.removeWhere((item) => item.id == id);
// //     } catch (e) {
// //       print('Error deleting order item with ID $id: $e');
// //     }
// //   }

// //   /// Update an existing order item
// //   Future<void> updateOrderItem(OrderItem orderItem) async {
// //     try {
// //       final record = await dataBase.pb
// //           .collection('order_item')
// //           .update(orderItem.id, body: orderItem.toJson());
// //       int index = _orderItems.indexWhere((item) => item.id == orderItem.id);
// //       if (index != -1) {
// //         _orderItems[index] = OrderItem.fromJson(record.data);
// //       }
// //     } catch (e) {
// //       print('Error updating order item with ID ${orderItem.id}: $e');
// //     }
// //   }

// //   Future<OrderItem?> getOrderItemByOrderID(String id) async {
// //     try {
// //       final record =
// //           await dataBase.pb.collection('order_item').getOne('order_id="$id"');
// //       return OrderItem.fromJson(record.data);
// //     } catch (e) {
// //       print('Error fetching order item with order ID $id: $e');
// //       return null;
// //     }
// //   }
// // }
// import 'package:project/model/order/order_item.dart';
// import 'package:project/model/database/pocketbase.dart';

// class OrderItemManager {
//   final DataBase dataBase = DataBase();

//   final List<OrderItem> _orderItems = [];

//   List<OrderItem> get orderItems => List.unmodifiable(_orderItems);

//   /// Fetch all order items from the database
//   Future<void> fetchOrderItems() async {
//     try {
//       final records = await dataBase.pb.collection('order_item').getFullList();
//       _orderItems.clear();
//       _orderItems
//           .addAll(records.map((record) => OrderItem.fromJson(record.toJson())));
//       print('Fetched order items: $_orderItems');
//     } catch (e) {
//       print('Error fetching order items: $e');
//     }
//   }

//   /// Fetch a single order item by ID
//   Future<OrderItem?> getOneOrderItem(String id) async {
//     try {
//       final record = await dataBase.pb.collection('order_item').getList(
//             filter: 'order_id = "$id"',
//           );
//       return OrderItem.fromJson(record.items.first.toJson());
//     } catch (e) {
//       print('Error fetching order item with ID $id: $e');
//       return null;
//     }
//   }

//   /// Add a new order item to the database
//   Future<void> addOrderItem(OrderItem orderItem) async {
//     try {
//       final record = await dataBase.pb
//           .collection('order_item')
//           .create(body: orderItem.toJson());
//       _orderItems.add(OrderItem.fromJson(record.toJson()));
//       print('Added order item: ${record.toJson()}');
//     } catch (e) {
//       print('Error adding order item: $e');
//     }
//   }

//   /// Delete an order item by ID
//   Future<void> deleteOrderItem(String id) async {
//     try {
//       await dataBase.pb.collection('order_item').delete(id);
//       _orderItems.removeWhere((item) => item.id == id);
//       print('Deleted order item with ID: $id');
//     } catch (e) {
//       print('Error deleting order item with ID $id: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>?> getOrderItems(String orderId) async {
//     final response = await dataBase.pb
//         .collection('order_item')
//         .getList(filter: 'order_id="$orderId"');
//     return response.items.map((item) => item.toJson()).toList();
//   }

//   /// Update an existing order item
//   Future<void> updateOrderItem(OrderItem orderItem) async {
//     try {
//       final record = await dataBase.pb
//           .collection('order_item')
//           .update(orderItem.id, body: orderItem.toJson());
//       int index = _orderItems.indexWhere((item) => item.id == orderItem.id);
//       if (index != -1) {
//         _orderItems[index] = OrderItem.fromJson(record.toJson());
//       }
//       print('Updated order item: ${record.toJson()}');
//     } catch (e) {
//       print('Error updating order item with ID ${orderItem.id}: $e');
//     }
//   }

//   /// Fetch order item by order ID
//   Future<OrderItem?> getOrderItemByOrderID(String id) async {
//     try {
//       final record =
//           await dataBase.pb.collection('order_item').getOne('order_id="$id"');
//       return OrderItem.fromJson(record.toJson());
//     } catch (e) {
//       print('Error fetching order item with order ID $id: $e');
//       return null;
//     }
//   }
// }
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
          .addAll(records.map((record) => OrderItem.fromJson(record.toJson())));
      print('Fetched order items: $_orderItems');
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
      return OrderItem.fromJson(record.items.first.toJson());
    } catch (e) {
      print('Error fetching order item with ID $id: $e');
      return null;
    }
  }

  /// Add a new order item to the database
  Future<void> addOrderItem(OrderItem orderItem) async {
    try {
      final record = await dataBase.pb
          .collection('order_item')
          .create(body: orderItem.toJson());
      _orderItems.add(OrderItem.fromJson(record.toJson()));
      print('Added order item: ${record.toJson()}');
    } catch (e) {
      print('Error adding order item: $e');
    }
  }

  /// Delete an order item by ID
  Future<void> deleteOrderItem(String id) async {
    try {
      await dataBase.pb.collection('order_item').delete(id);
      _orderItems.removeWhere((item) => item.id == id);
      print('Deleted order item with ID: $id');
    } catch (e) {
      print('Error deleting order item with ID $id: $e');
    }
  }

  /// Fetch order items by order ID and parse the 'items' field
  Future<List<Map<String, dynamic>>?> getOrderItems(String orderId) async {
    try {
      final response = await dataBase.pb
          .collection('order_item')
          .getList(filter: 'order_id="$orderId"');
      final items = response.items.map((item) {
        final data = item.toJson();
        final itemsField = data['items'] as Map<String, dynamic>?;
        return {
          'product_id': itemsField?['product_id']?.toString(),
          'quantity': itemsField?['quantity'] as int? ?? 1,
        };
      }).toList();
      print('Parsed order items for order $orderId: $items');
      return items;
    } catch (e) {
      print('Error fetching order items for order $orderId: $e');
      return [];
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
        _orderItems[index] = OrderItem.fromJson(record.toJson());
      }
      print('Updated order item: ${record.toJson()}');
    } catch (e) {
      print('Error updating order item with ID ${orderItem.id}: $e');
    }
  }

  /// Fetch order item by order ID
  Future<OrderItem?> getOrderItemByOrderID(String id) async {
    try {
      final record =
          await dataBase.pb.collection('order_item').getOne('order_id="$id"');
      return OrderItem.fromJson(record.toJson());
    } catch (e) {
      print('Error fetching order item with order ID $id: $e');
      return null;
    }
  }
}
