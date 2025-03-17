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

  Future<void> createNewCart(String userEmail) async {
    try {
      final userResponse = await cartDataBase.pb
          .collection('users')
          .getList(filter: 'email="$userEmail"');

      if (userResponse.items.isEmpty) {
        throw Exception('User not found');
      }

      final userId = userResponse.items.first.id;

      final existingCart = await cartDataBase.pb
          .collection('cart')
          .getList(filter: 'user_id="$userId"');

      if (existingCart.items.isNotEmpty) {
        cart = Cart.fromJson(existingCart.items.first.toJson());
        return;
      }

      final response = await cartDataBase.pb.collection('cart').create(
        body: {
          'user_id': userId,
          'product_id': [],
          'created': DateTime.now().toIso8601String(),
          'updated': DateTime.now().toIso8601String(),
        },
      );
      cart = Cart(
        collectionId: response.collectionId,
        collectionName: response.collectionName,
        id: response.id,
        userId: userId,
        productId: [],
        created: DateTime.parse(response.created),
        updated: DateTime.parse(response.updated),
      );
    } catch (e) {
      print('Error creating new cart: $e');
      throw e;
    }
  }

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
      final currentCart =
          await cartDataBase.pb.collection('cart').getOne(cart.id);
      List<String> updatedProductIds =
          List.from(currentCart.data['product_id'] as List<dynamic>)
              .map((id) => id.toString())
              .toList();

      updatedProductIds.remove(productId);

      await cartDataBase.pb.collection('cart').update(
        cart.id,
        body: {
          'product_id': updatedProductIds,
          'updated': DateTime.now().toIso8601String(),
        },
      );

      cart = cart.copyWith(
        productId: updatedProductIds,
        updated: DateTime.now(),
      );
    } catch (e) {
      print('Error removing product from cart: $e');
      throw e;
    }
  }
}
