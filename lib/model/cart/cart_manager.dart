import 'package:project/model/cart/cart.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/user/user.dart';

class CartManager {
  DataBase cartDataBase = DataBase();
  Cart cart = Cart(
    collectionId: '',
    collectionName: '',
    id: '',
    userId: '',
    productId: [],
    created: DateTime.now(),
    updated: DateTime.now(),
  );
  Future<void> fetchCartItemsByid(User user) async {
    try {
      final response = await cartDataBase.pb.collection('cart').getList(
            filter: 'user_id="${user.id}"',
          );
      cart = Cart.fromJson(response.items.first.toJson());
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> removeProductFromCart(String productId) async {
    try {
      // Fetch current cart data
      final currentCart =
          await cartDataBase.pb.collection('cart').getOne(cart.id);
      List<String> updatedProductIds =
          List.from(currentCart.data['product_id'] as List<dynamic>)
              .map((id) => id.toString())
              .toList();

      // Remove the product ID
      updatedProductIds.remove(productId);

      // Update the cart in the database
      await cartDataBase.pb.collection('cart').update(
        cart.id,
        body: {
          'product_id': updatedProductIds,
          'updated': DateTime.now().toIso8601String(),
        },
      );

      // Update local cart object
      cart = cart.copyWith(
        productId: updatedProductIds,
        updated: DateTime.now(),
      );
    } catch (e) {
      print('Error removing product from cart: $e');
      throw e; // Re-throw to handle in UI if needed
    }
  }
}
