import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/product/product.dart';

class ProductManager extends ChangeNotifier {
  final DataBase productDataBase = DataBase();
  final StreamController<List<Product>> _productsController =
      StreamController<List<Product>>.broadcast();

  Stream<List<Product>> get productsStream => _productsController.stream;

  List<Product> _allProducts = [];

  List get allProducts => _allProducts;
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
      notifyListeners();
    } catch (e) {
      print('Error fetching products: $e');
      _productsController.addError(e);
    }
  }

  Future<void> getProductsWithCategory(String category) async {
    try {
      final response =
          await productDataBase.pb.collection('products').getFullList(
                expand: "category_id",
                filter: "category_id.name = '$category'",
              );
      if (response.isEmpty) {
        _productsController.add([]);
      } else {
        final products =
            response.map((item) => Product.fromJson(item.toJson())).toList();
        _productsController.add(products);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching products with category: $e');
      _productsController.addError(e);
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response =
          await productDataBase.pb.collection('products').getOne(id);
      final product = Product.fromJson(response.toJson());
      return product;
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
      print('Filtered products: ${filteredProducts.map((p) => p.id).toList()}');
      _productsController.add(filteredProducts);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    print('Disposing ProductManager');
    _productsController.close();
    super.dispose();
  }
}
