import 'dart:async';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/product/product.dart';

class ProductManager {
  final DataBase productDataBase = DataBase();
  final StreamController<List<Product>> _productsController =
      StreamController<List<Product>>.broadcast();

  Stream<List<Product>> get productsStream => _productsController.stream;

  List<Product> _allProducts = []; // Lưu trữ tất cả sản phẩm để tìm kiếm

  Future<void> fetchProducts() async {
    try {
      final response =
          await productDataBase.pb.collection('products').getFullList();
      if (response.isEmpty) {
        print('No products found.');
        _productsController.add([]);
      } else {
        _allProducts =
            response.map((item) => Product.fromJson(item.toJson())).toList();
        _productsController.add(_allProducts);
      }
    } catch (e) {
      print('Error fetching products: $e');
      _productsController.addError(e);
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response =
          await productDataBase.pb.collection('products').getOne(id);
      return Product.fromJson(response.toJson());
    } catch (e) {
      print('Error fetching product: $e');
      rethrow;
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _productsController.add(_allProducts);
    } else {
      final filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      _productsController.add(filteredProducts);
    }
  }

  void dispose() {
    _productsController.close();
  }
}
