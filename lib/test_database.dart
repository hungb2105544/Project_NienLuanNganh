import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  PocketBase data = PocketBase("http://127.0.0.1:8090");

  try {
    final record = await data.collection('favorite_products').getFullList(
          expand: "id_users, id_products",
        );
    final formattedJson = const JsonEncoder.withIndent('  ')
        .convert(record[0].expand['id_products']);
    print(formattedJson);
  } catch (e) {
    print(e);
  }
}
