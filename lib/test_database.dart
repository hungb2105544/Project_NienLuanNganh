import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  PocketBase data = PocketBase("http://127.0.0.1:8090");

  try {
    final exitingRecord =
        await data.collection('favorite_products').getFullList(
              filter: "id_users = '314v4ihc7i7t7ho'",
            );
    print(jsonEncode(exitingRecord.first));
  } catch (e) {
    print(e);
  }
}
