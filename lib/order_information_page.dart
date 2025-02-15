import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/order/order.dart';
import 'package:project/model/order/order_item_manager.dart';
import 'package:project/model/product/product.dart';
import 'package:project/model/product/product_manager.dart';
import 'package:provider/provider.dart';

class OrderInformationPage extends StatefulWidget {
  const OrderInformationPage({super.key, required this.order});
  final Order order;
  @override
  State<OrderInformationPage> createState() => _OrderInformationPageState();
}

class _OrderInformationPageState extends State<OrderInformationPage> {
  final List<Product> _products = [];
  double _total = 0.0;

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
    if (orderItem == null) {
      print('Order Item not found.');
      return [];
    }
    List<Product> products =
        await getProductsOfOrder(orderItem.productId ?? []);
    return products;
  }

  Future<double> calculateTotal(Order order) async {
    double total = 0;
    List<Product> products = await getProductInOrder(order);
    for (var product in products) {
      total += product.price;
    }
    return total;
  }

  void fetchProducts() async {
    List<Product> products = await getProductInOrder(widget.order);
    double total = await calculateTotal(widget.order);
    setState(() {
      _products.clear();
      _products.addAll(products);
      _total = total;
    });
  }

  void deleteProduct(Order order, String productId) async {
    OrderItemManager orderItemManager = OrderItemManager();
    DataBase dataBase = DataBase();
    final orderItem = await orderItemManager.getOneOrderItem(order.id);
    final record = await dataBase.pb.collection('order_item').getList(
          filter: 'order_id= "${orderItem?.orderId}"',
        );
    print("\nOrderitem $record");
    if (orderItem == null) {
      print('Order Item not found.');
      return;
    }
    List<String> updatedProductIds = List.from(orderItem.productId);
    updatedProductIds.remove(productId);
    print(updatedProductIds);
    try {
      final body = <String, dynamic>{
        "product_id": updatedProductIds,
      };

      await dataBase.pb
          .collection('order_item')
          .update(record.items.first.id, body: body);
      print('Product removed successfully');
      fetchProducts(); // Cập nhật lại danh sách sản phẩm và tổng giá trị
    } catch (e) {
      print('\nError removing product: $e');
    }
  }

  @override
  void initState() {
    fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Information'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    'User information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullname ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              user?.phone ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Order Status: ${widget.order.status}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.access_time,
                        color: const Color.fromARGB(179, 0, 0, 0),
                      ),
                      SizedBox(width: 12),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    'List Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder<List<Product>>(
                  future: getProductInOrder(widget.order),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No products found.'));
                    } else {
                      return Column(
                        children: snapshot.data!.map((product) {
                          return ProductItemInOrder(
                            product: product,
                            quantity: 1,
                            onRemove: () {
                              deleteProduct(
                                  widget.order, product.id.toString());
                            },
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  child: FutureBuilder<double>(
                    future: calculateTotal(widget.order),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return Text("Total: ${snapshot.data}");
                      }
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print('Đã xác nhận đơn hàng');
                          },
                          child: Text('Xác nhận đơn hàng'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print('Đã hủy đơn hàng');
                          },
                          child: Text('Hủy đơn hàng'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border:
            Border.all(color: const Color.fromARGB(255, 0, 0, 0)!, width: 2),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "http://10.0.2.2:8090/api/files/products/${product.id}/${product.image}",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '₫${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Số lượng: $quantity',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Xóa sản phẩm',
          ),
        ],
      ),
    );
  }
}
