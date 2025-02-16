import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  PocketBase data = PocketBase("http://127.0.0.1:8090");

  try {
    final record = await data.collection('address').getFullList();
    final formattedJson = const JsonEncoder.withIndent('  ')
        .convert(record.map((r) => r.data).toList());
    print(formattedJson);
  } catch (e) {
    print(e);
  }
}
