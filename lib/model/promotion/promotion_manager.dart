import 'package:flutter/material.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/promotion/promotion.dart';

class PromotionManager extends ChangeNotifier {
  List<Promotion> _promotions = [];
  Promotion? _promotion;
  final DataBase promotionDatabase = DataBase();
  bool _isLoading = false;

  Promotion? get promotion => _promotion;

  List<Promotion> get promotions => List.unmodifiable(_promotions);

  bool get isLoading => _isLoading;

  Future<void> getAllPromotions() async {
    try {
      _isLoading = true;
      notifyListeners();

      final records =
          await promotionDatabase.pb.collection('promotions').getFullList();
      final newPromotions =
          records.map((e) => Promotion.fromJson(e.toJson())).toList();

      if (_promotions != newPromotions) {
        _promotions = newPromotions;
      }
    } catch (e) {
      throw Exception('Failed to fetch promotions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPromotionById(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final record =
          await promotionDatabase.pb.collection('promotions').getOne(id);
      final newPromotion = Promotion.fromJson(record.toJson());

      if (_promotion != newPromotion) {
        _promotion = newPromotion;
      }
    } catch (e) {
      throw Exception('Failed to fetch promotion by ID: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPromotionByListId(List<String> ids) async {
    try {
      _isLoading = true;
      notifyListeners();
      final List<Promotion> newPromotions = await Future.wait(
        ids.map((id) async {
          final record =
              await promotionDatabase.pb.collection('promotions').getOne(id);
          return Promotion.fromJson(record.toJson());
        }),
      );

      if (_promotions != newPromotions) {
        _promotions = newPromotions;
      }
    } catch (e) {
      throw Exception('Failed to fetch promotions by list of IDs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _promotions = [];
    _promotion = null;
    notifyListeners();
  }
}
