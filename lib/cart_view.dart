import 'package:flutter/material.dart';
import 'package:project/component/cart_item.dart';
import 'package:project/model/cart/cart.dart';
import 'package:project/model/product/product.dart';
import 'package:project/model/product/product_manager.dart';

class CartView extends StatefulWidget {
  const CartView({
    super.key,
    required this.cart,
  });
  final Cart cart;
  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late int total = 0;
  final List<Product> listProduct = [];
  final ProductManager productManager = ProductManager();
  Future<void> fetchProduct(Cart cart) async {
    List<Product> list = [];
    for (var item in cart.productId) {
      final product = await productManager.getProductById(item);
      list.add(product);
    }

    setState(() {
      listProduct.addAll(list);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProduct(widget.cart);
    total = 0;
  }

  void updateTotal(int change) {
    setState(() {
      total += change;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('CartView');
    print('${widget.cart}\n');
    print(' Deg bug in Cart View : \n ${listProduct}');
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Center(
                child: Padding(
              padding: const EdgeInsets.only(right: 50),
              child: Text('Cart'),
            )),
          ),
          body: ListView(children: [
            for (var item in listProduct)
              CartItem(
                product: item,
                onTotalChanged: updateTotal,
              ),
          ]),
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
                      backgroundColor: Colors.black, // Elegant black theme
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5, // Adds depth
                      shadowColor: Colors.black45,
                    ),
                    onPressed: () {
                      // Handle checkout logic
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
