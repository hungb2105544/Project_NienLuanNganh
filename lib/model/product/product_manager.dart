import 'dart:async';

import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/product/product.dart';

// class ProductManager {
class ProductManager {
  final DataBase productDataBase = DataBase();
  final StreamController<List<Product>> _productsController =
      StreamController<List<Product>>.broadcast();

  Stream<List<Product>> get productsStream => _productsController.stream;

  Future<void> fetchProducts() async {
    try {
      final response =
          await productDataBase.pb.collection('products').getFullList();
      if (response.isEmpty) {
        print('No products found with the given filter and sort.');
        _productsController.add([]);
      } else {
        final products =
            response.map((item) => Product.fromJson(item.toJson())).toList();
        _productsController.add(products);
      }
    } catch (e) {
      print('Error fetching products: $e');
      _productsController.addError(e);
    }
  }

  Future<Product> getProductById(String id) async {
    Product product;
    try {
      final response =
          await productDataBase.pb.collection('products').getOne(id);
      product = Product.fromJson(response.toJson());
    } catch (e) {
      print('Error fetching product: $e');
      rethrow;
    }
    return product;
  }

  void dispose() {
    _productsController.close(); // Đóng stream controller khi không cần thiết
  }
}
