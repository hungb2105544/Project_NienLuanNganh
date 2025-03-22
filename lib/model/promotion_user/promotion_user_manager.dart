import 'package:flutter/material.dart';
import 'package:project/model/promotion/promotion.dart';
import 'package:project/model/database/pocketbase.dart';
import 'package:project/model/promotion_user/promotion_user.dart';

class PromotionUserManager extends ChangeNotifier {
  List<Promotion> promotionsUser = [];
  List<Promotion> get promotions => promotionsUser;

  Promotion? _promotion;
  Promotion? get promotion => _promotion;

  final DataBase promotionUserDatabase = DataBase();

  Future<void> getPromotionByUserId(String id) async {
    try {
      final records = await promotionUserDatabase.pb
          .collection('user_promotions')
          .getFullList(filter: "user_id = '$id'");
      promotionsUser = [];
      for (var record in records) {
        final promotionRecord = await promotionUserDatabase.pb
            .collection('promotions')
            .getOne(record.data['promotion_id']);
        promotionsUser.add(Promotion.fromJson(promotionRecord.toJson()));
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch promotions by user ID: $e');
    }
  }

  Future<void> getPromotionByPromotionId(String id) async {
    try {
      final records = await promotionUserDatabase.pb
          .collection('user_promotions')
          .getFullList(filter: "promotion_id = '$id'");

      if (records.isEmpty) {
        _promotion = null;
      } else {
        final promotionRecord =
            await promotionUserDatabase.pb.collection('promotions').getOne(id);
        _promotion = Promotion.fromJson(promotionRecord.toJson());
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch promotion by promotion ID: $e');
    }
  }

  Future<void> usePromotion(PromotionUser promotionUser) async {
    try {
      if (promotionUser.isUsed) {
        throw Exception('Promotion has already been used');
      }
      final body = {
        'is_used': true,
      };
      await promotionUserDatabase.pb
          .collection('user_promotions')
          .update(promotionUser.id, body: body);
      if (promotionsUser.isNotEmpty) {
        await getPromotionByUserId(promotionUser.userId);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to use promotion: $e');
    }
  }

  Future<void> savePromotion(String userId, String promotionId) async {
    if (userId.isEmpty || promotionId.isEmpty) {
      throw Exception('User ID and Promotion ID cannot be empty');
    }

    try {
      final existingRecords = await promotionUserDatabase.pb
          .collection('user_promotions')
          .getFullList(
              filter: "user_id = '$userId' && promotion_id = '$promotionId'");
      if (existingRecords.isNotEmpty) {
        throw Exception('Promotion already saved for this user');
      }

      final now = DateTime.now().toIso8601String();
      final body = {
        'user_id': userId,
        'promotion_id': promotionId,
        'saved_at': now,
        'is_used': false,
        'created': now,
        'updated': now,
      };

      await promotionUserDatabase.pb
          .collection('user_promotions')
          .create(body: body);

      await getPromotionByUserId(userId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save promotion: $e');
    }
  }

  void clear() {
    promotionsUser = [];
    _promotion = null;
    notifyListeners();
  }
}
