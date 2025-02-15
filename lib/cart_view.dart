import 'package:flutter/material.dart';
import 'package:project/component/cart_item.dart';

class CartView extends StatefulWidget {
  const CartView({
    super.key,
  });
  // final List<CartItem> cartItems;  required this.cartItems
  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late int total = 0;

  Set<Products> product = {
    Products(name: 'Iphone 13', price: 20000000),
    Products(name: 'Iphone 13', price: 20000000),
    Products(name: 'Iphone 13', price: 20000000),
    Products(name: 'Iphone 13', price: 20000000),
  };

  @override
  void initState() {
    super.initState();
    total = 0;
  }

  void updateTotal(int change) {
    setState(() {
      total += change;
    });
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
            )),
          ),
          body: ListView(children: [
            for (var item in product)
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
                  // color: Colors.cyan[900],
                  margin: EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.cyan[900]),
                    ),
                    onPressed: () {
                      //Thanh toán xử lí backend nhập lên cơ sở dữ liệu
                    },
                    child: Text(
                      'Thanh toán',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


                                  // Navigator.pop(
                                  //   context,
                                  //   PageRouteBuilder(
                                  //     pageBuilder: (context, animation,
                                  //             secondaryAnimation) =>
                                  //         Login(),
                                  //     transitionsBuilder: (context, animation,
                                  //         secondaryAnimation, child) {
                                  //       const begin = Offset(0.0, 1.0);
                                  //       const end = Offset.zero;
                                  //       const curve = Curves.easeInOut;

                                  //       var tween = Tween(
                                  //               begin: begin, end: end)
                                  //           .chain(CurveTween(curve: curve));
                                  //       var offsetAnimation =
                                  //           animation.drive(tween);

                                  //       return SlideTransition(
                                  //         position: offsetAnimation,
                                  //         child: FadeTransition(
                                  //           opacity: animation,
                                  //           child: child,
                                  //         ),
                                  //       );
                                  //     },
                                  //   ),
                                  // );