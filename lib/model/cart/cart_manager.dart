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
}
