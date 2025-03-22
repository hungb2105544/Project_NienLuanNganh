import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  PocketBase data = PocketBase("http://127.0.0.1:8090");

  try {
    final exitingRecord = await data.collection('user_promotions').getFullList(
          filter: "user_id = 'yi0p96o01g06380'",
        );
    print(jsonEncode(exitingRecord));
  } catch (e) {
    print(e);
  }
}
