import 'dart:async';

import 'package:project/model/category/category.dart';
import 'package:project/model/database/pocketbase.dart';

class CategoryManager {
  final DataBase categoryDataBase = DataBase();
  final StreamController<List<Category>> _categoriesController =
      StreamController<List<Category>>.broadcast();

  Stream<List<Category>> get categoriesStream => _categoriesController.stream;

  Future<void> fetchCategories() async {
    try {
      final response =
          await categoryDataBase.pb.collection('categories').getFullList();
      if (response.isEmpty) {
        print('No categories found with the given filter and sort.');
        _categoriesController.add([]);
      } else {
        final categories =
            response.map((item) => Category.fromJson(item.toJson())).toList();
        _categoriesController.add(categories);
      }
    } catch (e) {
      print('Error fetching categories: $e');
      _categoriesController.addError(e);
    }
  }

  void dispose() {
    _categoriesController.close(); // Đóng stream controller khi không cần thiết
  }
}
