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
          'Orders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view orders.'))
          : FutureBuilder<List<Order>>(
              future: _fetchOrders(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8, top: 8),
                      child: OrderItem(order: snapshot.data![index]),
                    );
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
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.receipt_long_outlined, size: 40),
          title: Text(
            'Order ID: ${order.orderCode}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Order Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}', // Giả sử order.date là một String
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderInformationPage(
                        order: order,
                      )),
            )
          },
        ),
      ),
    );
  }
}
