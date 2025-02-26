import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/component/cart_item.dart';
import 'package:project/model/cart/cart.dart';
import 'package:project/model/product/product.dart';
import 'package:project/model/product/product_manager.dart';
import 'package:project/model/user/user.dart';
import 'package:project/order_temp.dart';
import 'package:project/model/cart/cart_manager.dart';
import 'package:provider/provider.dart';

class CartView extends StatefulWidget {
  const CartView({
    super.key,
    required this.cart,
    required this.user,
  });
  final Cart cart;
  final User user;

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late int total = 0;
  late List<String> listId = [];
  final List<Product> listProduct = [];
  final ProductManager productManager = ProductManager();
  final CartManager cartManager = CartManager();

  Future<void> fetchProduct(Cart cart) async {
    List<Product> list = [];
    for (var item in cart.productId) {
      final product = await productManager.getProductById(item);
      list.add(product);
    }
    setState(() {
      listProduct.addAll(list);
      listId = cart.productId;
    });
  }

  @override
  void initState() {
    super.initState();
    cartManager.cart = widget.cart;
    fetchProduct(widget.cart);
    total = 0;
  }

  void updateTotal(int change) {
    setState(() {
      total += change;
    });
  }

  void updateListProduct(Function(List<String>) updateFunction) {
    setState(() {
      listId = updateFunction(listId);
    });
  }

  Future<void> removeProduct(Product product) async {
    try {
      await cartManager.removeProductFromCart(product.id);
      setState(() {
        listProduct.removeWhere((item) => item.id == product.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 50),
                child: Text('Cart'),
              ),
            ),
          ),
          body: listProduct.isEmpty
              ? Center(child: Text('Your cart is empty'))
              : ListView(
                  children: [
                    for (var item in listProduct)
                      CartItem(
                        product: item,
                        onListProductChanged: updateListProduct,
                        onTotalChanged: updateTotal,
                        onDelete: () => removeProduct(item),
                      ),
                  ],
                ),
          bottomNavigationBar: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Text(
                    'Tổng tiền: $total VND',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black45,
                    ),
                    onPressed: listProduct.isEmpty
                        ? null
                        : () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderTemp(
                                    listId: listId,
                                  ),
                                ),
                              )
                            },
                    child: Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
