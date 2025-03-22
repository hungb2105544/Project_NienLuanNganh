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
    items: [],
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
          'items': [],
          'created': DateTime.now().toIso8601String(),
          'updated': DateTime.now().toIso8601String(),
        },
      );
      cart = Cart(
        collectionId: response.collectionId,
        collectionName: response.collectionName,
        id: response.id,
        userId: userId,
        items: [],
        created: DateTime.parse(response.created),
        updated: DateTime.parse(response.updated),
      );
      print('Created new cart: $cart');
    } catch (e) {
      print('Error creating new cart: $e');
      throw e;
    }
  }

  Future<void> fetchCartItemsById(User user) async {
    try {
      final response = await cartDataBase.pb.collection('cart').getList(
            filter: 'user_id="${user.id}"',
          );
      if (response.items.isNotEmpty) {
        cart = Cart.fromJson(response.items.first.toJson());
        print('Fetched cart: $cart');
      } else {
        print('No cart found for user: ${user.id}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> removeProductFromCart(String productId, String size) async {
    try {
      final currentCart =
          await cartDataBase.pb.collection('cart').getOne(cart.id);
      List<Map<String, dynamic>> updatedItems =
          List.from(currentCart.toJson()['items'] as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

      updatedItems.removeWhere(
          (item) => item['product_id'] == productId && item['size'] == size);

      await cartDataBase.pb.collection('cart').update(
        cart.id,
        body: {
          'items': updatedItems,
          'updated': DateTime.now().toIso8601String(),
        },
      );

      cart = cart.copyWith(
        items: updatedItems,
        updated: DateTime.now(),
      );
      print('Removed item from cart: $cart');
    } catch (e) {
      print('Error removing product from cart: $e');
      throw e;
    }
  }

  Future<void> addProductToCart(
      String productId, String size, int quantity) async {
    try {
      final currentCart =
          await cartDataBase.pb.collection('cart').getOne(cart.id);
      List<Map<String, dynamic>> updatedItems =
          List.from(currentCart.toJson()['items'] as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

      updatedItems.add({
        'product_id': productId,
        'size': size,
        'quantity': quantity,
      });

      await cartDataBase.pb.collection('cart').update(
        cart.id,
        body: {
          'items': updatedItems,
          'updated': DateTime.now().toIso8601String(),
        },
      );

      cart = cart.copyWith(
        items: updatedItems,
        updated: DateTime.now(),
      );
      print('Added item to cart: $cart');
    } catch (e) {
      print('Error adding product to cart: $e');
      throw e;
    }
  }
}
