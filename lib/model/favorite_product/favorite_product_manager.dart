import 'package:flutter/material.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/favorite_product/favorite_product.dart';
import 'package:project/model/user/user.dart';

class FavoriteProductManager extends ChangeNotifier {
  List<String> _favoriteProductIds = [];
  List<String> get favoriteProductIds => _favoriteProductIds;

  final DataBase favoriteProductDataBase = DataBase();

  Future<void> addFavoriteProduct(String productId, User user) async {
    if (!_favoriteProductIds.contains(productId)) {
      try {
        final existingRecords = await favoriteProductDataBase.pb
            .collection('favorite_products')
            .getFullList(
              filter: "id_users = '${user.id}'",
            );

        if (existingRecords.isEmpty) {
          final newFavorite = FavoriteProduct(
            id: '',
            userId: user.id,
            productIds: [productId],
            created: DateTime.now(),
            updated: DateTime.now(),
          );
          await favoriteProductDataBase.pb
              .collection('favorite_products')
              .create(body: newFavorite.toJson());
          _favoriteProductIds.add(productId);
        } else {
          final record = existingRecords.first;
          final favoriteProduct = FavoriteProduct.fromJson(record.data);
          final updatedProductIds =
              List<String>.from(favoriteProduct.productIds);

          if (!updatedProductIds.contains(productId)) {
            updatedProductIds.add(productId);
            await favoriteProductDataBase.pb
                .collection('favorite_products')
                .update(record.id, body: {
              'id_products': updatedProductIds,
              'updated': DateTime.now().toIso8601String(),
            });
            _favoriteProductIds.add(productId);
          }
        }
        notifyListeners();
      } catch (e) {
        print("Lỗi khi thêm sản phẩm yêu thích: $e");
        _favoriteProductIds.remove(productId);
        rethrow;
      }
    }
  }

  Future<void> createFavoriteProductRecord(User user) async {
    try {
      final existingRecords = await favoriteProductDataBase.pb
          .collection('favorite_products')
          .getFullList(
            filter: "id_users = '${user.id}'",
          );
      if (existingRecords.isEmpty) {
        final newFavorite = FavoriteProduct(
          id: '',
          userId: user.id,
          productIds: [],
          created: DateTime.now(),
          updated: DateTime.now(),
        );
        await favoriteProductDataBase.pb
            .collection('favorite_products')
            .create(body: newFavorite.toJson());
        print("Đã tạo bản ghi favorite_products cho user ${user.id}");
        _favoriteProductIds = [];
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi khi tạo bản ghi favorite_products: $e");
      rethrow;
    }
  }

  Future<void> removeFavoriteProduct(String productId, User user) async {
    if (_favoriteProductIds.contains(productId)) {
      try {
        final existingRecords = await favoriteProductDataBase.pb
            .collection('favorite_products')
            .getFullList(
              filter: "id_users = '${user.id}'",
            );

        if (existingRecords.isNotEmpty) {
          final record = existingRecords.first;
          final favoriteProduct = FavoriteProduct.fromJson(record.data);
          final updatedProductIds =
              List<String>.from(favoriteProduct.productIds);

          if (updatedProductIds.contains(productId)) {
            updatedProductIds.remove(productId);
            await favoriteProductDataBase.pb
                .collection('favorite_products')
                .update(record.id, body: {
              'id_products': updatedProductIds,
              'updated': DateTime.now().toIso8601String(),
            });
            _favoriteProductIds.remove(productId);
            notifyListeners();
          }
        }
      } catch (e) {
        print("Lỗi khi xóa sản phẩm yêu thích: $e");
        _favoriteProductIds.add(productId);
        rethrow;
      }
    }
  }
}
