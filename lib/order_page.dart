import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/model/order/order.dart';
import 'package:project/model/order/orders_manager.dart';
import 'package:project/order_information_page.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  Future<List<Order>> _fetchOrders(String userId) async {
    try {
      return await OrderManager().getOrdersByUserId(userId);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Please log in to view orders.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : FutureBuilder<List<Order>>(
              future: _fetchOrders(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No orders found.',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return OrderItem(order: snapshot.data![index]);
                  },
                );
              },
            ),
    );
  }
}

class OrderItem extends StatelessWidget {
  const OrderItem({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: const Icon(Icons.receipt_long_outlined,
              size: 40, color: Colors.black),
          title: Text(
            'Order ID: ${order.orderCode}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'View',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderInformationPage(order: order)),
            );
          },
        ),
      ),
    );
  }
}
