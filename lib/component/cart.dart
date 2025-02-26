import 'package:flutter/material.dart';
import 'package:project/cart_view.dart'; // Verify this import is correct
import 'package:project/model/cart/cart.dart';
import 'package:project/model/user/user.dart';

class CartIcon extends StatefulWidget {
  const CartIcon({
    super.key,
    required this.numberOfCart,
    required this.cart,
    required this.user,
    required this.onRefresh,
  });
  final int numberOfCart;
  final Cart cart;
  final User user;
  final VoidCallback onRefresh;

  @override
  State<CartIcon> createState() => _CartIconState();
}

class _CartIconState extends State<CartIcon> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.numberOfCart > 0)
          Positioned(
            right: 3.5,
            top: 0.3,
            child: ClipOval(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.02,
                width: MediaQuery.of(context).size.width * 0.035,
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: Center(
                  child: Text(
                    '${widget.numberOfCart}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    CartView(
                  // Instantiate CartView
                  cart: widget.cart,
                  user: widget.user,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
              ),
            ).then((_) {
              if (context.mounted) {
                widget.onRefresh();
              }
            });
          },
          icon: const Icon(Icons.shopping_cart),
          color: Colors.black,
        ),
      ],
    );
  }
}
