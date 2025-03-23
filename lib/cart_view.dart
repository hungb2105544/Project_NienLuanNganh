import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/component/cart_item.dart';
import 'package:project/model/cart/cart.dart';
import 'package:project/model/product/product.dart';
import 'package:project/model/product/product_manager.dart';
import 'package:project/model/user/user.dart';
import 'package:project/order_temp.dart';
import 'package:project/model/cart/cart_manager.dart';

class CartView extends StatefulWidget {
  final Cart cart;
  final User user;

  const CartView({
    super.key,
    required this.cart,
    required this.user,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late final CartManager cartManager;
  late final ProductManager productManager;
  final Map<String, Product> cartProducts = {};
  final Set<String> selectedItems = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cartManager = CartManager();
    productManager = ProductManager();
    cartManager.cart = widget.cart;
    _loadCartProducts();
  }

  Future<void> _loadCartProducts() async {
    try {
      final productIds =
          widget.cart.items.map((item) => item['product_id'] as String).toSet();
      final products = await Future.wait(
        productIds.map((id) => productManager.getProductById(id)),
      );

      if (mounted) {
        setState(() {
          cartProducts.clear();
          for (var product in products) {
            cartProducts[product.id] = product;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorSnackBar('Failed to load cart: $e');
      }
    }
  }

  double get totalAmount {
    return widget.cart.items.fold(0, (sum, item) {
      final product = cartProducts[item['product_id']];
      final quantity = item['quantity'] as int? ?? 1;
      final price = product?.price ?? 0;
      final itemKey = "${item['product_id']}-${item['size']}";

      return selectedItems.contains(itemKey) ? sum + (price * quantity) : sum;
    });
  }

  Future<void> _removeProduct(String productId, String size) async {
    try {
      await cartManager.removeProductFromCart(productId, size);
      setState(() {
        widget.cart.items.removeWhere(
          (item) => item['product_id'] == productId && item['size'] == size,
        );
        selectedItems.remove("$productId-$size");
      });
    } catch (e) {
      _showErrorSnackBar('Failed to remove product: $e');
    }
  }

  void _toggleItemSelection(String productId, String size, bool isSelected) {
    final itemKey = "$productId-$size";
    setState(() {
      if (isSelected) {
        selectedItems.add(itemKey);
      } else {
        selectedItems.remove(itemKey);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.cart.items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.builder(
                  itemCount: widget.cart.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.cart.items[index];
                    final product = cartProducts[item['product_id']];
                    if (product == null) return const SizedBox.shrink();

                    final itemKey = "${item['product_id']}-${item['size']}";
                    final isSelected = selectedItems.contains(itemKey);

                    return CartItem(
                      product: product,
                      size: item['size'] as String,
                      quantity: item['quantity'] as int? ?? 1,
                      isSelected: isSelected,
                      onToggleSelection: (selected) => _toggleItemSelection(
                          product.id, item['size'] as String, selected),
                      onDelete: () => _removeProduct(
                        product.id,
                        item['size'] as String,
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 80,
        child: Row(
          children: [
            Text(
              'Total: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format(totalAmount)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: selectedItems.isEmpty
                  ? null
                  : () {
                      final selectedCartItems = widget.cart.items.where((item) {
                        final itemKey = "${item['product_id']}-${item['size']}";
                        return selectedItems.contains(itemKey);
                      }).toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTemp(
                            cartItems: selectedCartItems,
                          ),
                        ),
                      );
                    },
              child: const Text(
                'Place Order',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
