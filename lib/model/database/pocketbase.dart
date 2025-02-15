import 'package:pocketbase/pocketbase.dart';

class DataBase {
  late final PocketBase pb;
  DataBase() {
    pb = PocketBase('http://10.0.2.2:8090'); // URL PocketBase
  }
}
