import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  PocketBase data = PocketBase("http://127.0.0.1:8090");

  try {
    // final records = await data.collection('categories').getList(sort: '-created'
    //     // filter: 'user_id="314v4ihc7i7t7ho"', // Đúng cú pháp PBQL
    //     );
    // final records = await data.collection('orders').getList(
    //       filter: 'userid="314v4ihc7i7t7ho"',
    //       sort: '-created',
    //     );
    final records = await data.collection('cart').getFullList(
          filter: 'user_id = "314v4ihc7i7t7ho"',
        );  
    final formattedJson =
        const JsonEncoder.withIndent('  ').convert(records.first);
    print(formattedJson);
  } catch (e) {
    print(e);
  }
}

// console.log(latestRecord);
