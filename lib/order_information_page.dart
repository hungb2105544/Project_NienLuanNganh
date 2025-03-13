// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:project/model/address/address.dart';
// import 'package:project/model/address/address_manager.dart';
// import 'package:project/model/order/orders_manager.dart';
// import 'package:provider/provider.dart';
// import 'package:project/auth_service.dart';
// import 'package:project/model/order/order.dart';
// import 'package:project/model/order/order_item_manager.dart';
// import 'package:project/model/product/product.dart';
// import 'package:project/model/product/product_manager.dart';

// class OrderInformationPage extends StatefulWidget {
//   const OrderInformationPage({super.key, required this.order});
//   final Order order;

//   @override
//   State<OrderInformationPage> createState() => _OrderInformationPageState();
// }

// class _OrderInformationPageState extends State<OrderInformationPage> {
//   late Order _currentOrder;

//   @override
//   void initState() {
//     super.initState();
//     _currentOrder = widget.order;
//   }

//   Future<List<Product>> getProductsOfOrder(List<String> idProducts) async {
//     ProductManager productManager = ProductManager();
//     List<Product> products = [];
//     for (var id in idProducts) {
//       final product = await productManager.getProductById(id);
//       products.add(product);
//     }
//     return products;
//   }

//   Future<List<Product>> getProductInOrder(Order order) async {
//     OrderItemManager orderItemManager = OrderItemManager();
//     final orderItem = await orderItemManager.getOneOrderItem(order.id);
//     if (orderItem == null) return [];
//     return await getProductsOfOrder(orderItem.productId ?? []);
//   }

//   Future<Address?> getAddressById(String id) async {
//     AddressManager addressManager = AddressManager();
//     return await addressManager.getOneAddress(id);
//   }

//   Future<void> confirmOrder() async {
//     OrderManager orderManager = OrderManager();
//     final updatedOrder = widget.order.copyWith(status: 'shipped');

//     try {
//       await orderManager.updateOrder(widget.order.id, updatedOrder);
//       setState(() {
//         _currentOrder = updatedOrder;
//       });
//     } catch (e) {
//       print('Error confirming order: $e');
//     }
//   }

//   Future<double> calculateTotal(List<Product> products) async {
//     double total = 0;
//     for (var product in products) {
//       total += product.price;
//     }
//     return total;
//   }

//   String formatDateTime(DateTime dateTime) {
//     return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);
//     final user = authService.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Order Information'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
//         child: FutureBuilder<List<Product>>(
//           future: getProductInOrder(widget.order),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text('No products found.'));
//             } else {
//               final products = snapshot.data!;
//               return FutureBuilder<double>(
//                 future: calculateTotal(products),
//                 builder: (context, totalSnapshot) {
//                   return FutureBuilder<Address?>(
//                     future: getAddressById(widget.order.addressId),
//                     builder: (context, addressSnapshot) {
//                       final address = addressSnapshot.data;
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildUserInfo(user),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Address',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 16),
//                           if (address != null)
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 6,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Địa chỉ: ${address.street}, ${address.city}, ${address.state}',
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Thời gian: ${formatDateTime(widget.order.created)}',
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Information',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           if (address != null)
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 6,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Mã đơn hàng: ${widget.order.orderCode}',
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Phương thức thanh toán : ${widget.order.paymentMethod}',
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'List Products',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           Expanded(
//                             child: ListView.builder(
//                               physics: const BouncingScrollPhysics(),
//                               itemCount: products.length,
//                               itemBuilder: (context, index) {
//                                 final product = products[index];
//                                 return ProductItemInOrder(
//                                   product: product,
//                                   quantity: 1,
//                                   onRemove: () {
//                                     print('Product removed: ${product.id}');
//                                   },
//                                 );
//                               },
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           _buildTotalAndButtons(totalSnapshot.data ?? 0.0),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildUserInfo(user) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.black,
//             child: Icon(Icons.person, size: 30, color: Colors.white),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(user?.fullname ?? 'Unknown',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Text(user?.phone ?? 'Unknown',
//                     style:
//                         const TextStyle(fontSize: 16, color: Colors.black54)),
//                 const SizedBox(height: 4),
//                 Text('Order Status: ${widget.order.status}',
//                     style: const TextStyle(
//                         fontSize: 14, fontWeight: FontWeight.w500)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotalAndButtons(double total) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: Text(
//               "Tổng: ₫${total.toStringAsFixed(0)}",
//               key: ValueKey(total),
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color.fromARGB(255, 0, 0, 0),
//               ),
//             ),
//           ),
//           if (widget.order.status == "processing")
//             ElevatedButton.icon(
//               onPressed: () => confirmOrder(),
//               icon:
//                   const Icon(Icons.check_circle, size: 22, color: Colors.white),
//               label: const Text('Đã nhận hàng'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green.shade600,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 4,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class ProductItemInOrder extends StatelessWidget {
//   final int quantity;
//   final Product product;
//   final VoidCallback onRemove;

//   const ProductItemInOrder({
//     super.key,
//     required this.product,
//     required this.quantity,
//     required this.onRemove,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: ListTile(
//         leading: Hero(
//           tag: product.id,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.network(
//               "http://10.0.2.2:8090/api/files/products/${product.id}/${product.image}",
//               width: 60,
//               height: 60,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         title: Text(product.name,
//             style: const TextStyle(fontWeight: FontWeight.w600)),
//         subtitle:
//             Text('₫${product.price.toStringAsFixed(0)} | Số lượng: $quantity'),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/model/address/address.dart';
import 'package:project/model/address/address_manager.dart';
import 'package:project/model/order/orders_manager.dart';
import 'package:provider/provider.dart';
import 'package:project/auth_service.dart';
import 'package:project/model/order/order.dart';
import 'package:project/model/order/order_item_manager.dart';
import 'package:project/model/product/product.dart';
import 'package:project/model/product/product_manager.dart';

class OrderInformationPage extends StatefulWidget {
  const OrderInformationPage({super.key, required this.order});
  final Order order;

  @override
  State<OrderInformationPage> createState() => _OrderInformationPageState();
}

class _OrderInformationPageState extends State<OrderInformationPage> {
  late Order _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  Future<List<Product>> getProductsOfOrder(List<String> idProducts) async {
    ProductManager productManager = ProductManager();
    List<Product> products = [];
    for (var id in idProducts) {
      final product = await productManager.getProductById(id);
      products.add(product);
    }
    return products;
  }

  Future<List<Product>> getProductInOrder(Order order) async {
    OrderItemManager orderItemManager = OrderItemManager();
    final orderItem = await orderItemManager.getOneOrderItem(order.id);
    if (orderItem == null) return [];
    return await getProductsOfOrder(orderItem.productId ?? []);
  }

  Future<Address?> getAddressById(String id) async {
    AddressManager addressManager = AddressManager();
    return await addressManager.getOneAddress(id);
  }

  Future<void> confirmOrder() async {
    OrderManager orderManager = OrderManager();
    final updatedOrder = _currentOrder.copyWith(status: 'shipped');

    try {
      await orderManager.updateOrder(_currentOrder.id, updatedOrder);
      setState(() {
        _currentOrder = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được xác nhận thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xác nhận đơn hàng: ${e.toString()}')),
      );
    }
  }

  Future<double> calculateTotal(List<Product> products) async {
    double total = 0;
    for (var product in products) {
      total += product.price;
    }
    return total;
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Information'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: getProductInOrder(_currentOrder),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            final products = snapshot.data!;
            return FutureBuilder<double>(
              future: calculateTotal(products),
              builder: (context, totalSnapshot) {
                return FutureBuilder<Address?>(
                  future: getAddressById(_currentOrder.addressId),
                  builder: (context, addressSnapshot) {
                    final address = addressSnapshot.data;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserInfo(user),
                          const SizedBox(height: 16),
                          const Text(
                            'Address',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          if (address != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Địa chỉ: ${address.street}, ${address.city}, ${address.state}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thời gian: ${formatDateTime(_currentOrder.created)}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Information',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (address != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mã đơn hàng: ${_currentOrder.orderCode}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Phương thức thanh toán : ${_currentOrder.paymentMethod}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'List Products',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductItemInOrder(
                                product: product,
                                quantity: 1,
                                onRemove: () {
                                  print('Product removed: ${product.id}');
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildTotalAndButtons(totalSnapshot.data ?? 0.0),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildUserInfo(user) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullname ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.phone ?? 'Unknown',
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 4),
                Text('Order Status: ${_currentOrder.status}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAndButtons(double total) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              "Tổng: ₫${total.toStringAsFixed(0)}",
              key: ValueKey(total),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          if (_currentOrder.status == "processing")
            ElevatedButton.icon(
              onPressed: confirmOrder,
              icon:
                  const Icon(Icons.check_circle, size: 22, color: Colors.white),
              label: const Text('Đã nhận hàng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }
}

class ProductItemInOrder extends StatelessWidget {
  final int quantity;
  final Product product;
  final VoidCallback onRemove;

  const ProductItemInOrder({
    super.key,
    required this.product,
    required this.quantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Hero(
          tag: product.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "http://10.0.2.2:8090/api/files/products/${product.id}/${product.image}",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle:
            Text('₫${product.price.toStringAsFixed(0)} | Số lượng: $quantity'),
      ),
    );
  }
}
