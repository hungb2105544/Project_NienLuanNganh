import 'package:project/model/address/address.dart';
import 'package:project/model/database/pocketbase.dart';

class AddressManager {
  final DataBase dataBase = DataBase();

  final List<Address> _addresses = [];

  List<Address> get addresses => List.unmodifiable(_addresses);

  /// Fetch all addresses from the database
  Future<void> fetchAddresses() async {
    try {
      final records = await dataBase.pb.collection('address').getFullList();
      _addresses.clear();
      _addresses.addAll(records.map((record) => Address.fromJson(record.data)));
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }

  /// Add a new address to the database
  Future<void> addAddress(Address address) async {
    try {
      final record = await dataBase.pb
          .collection('address')
          .create(body: address.toJson());
      _addresses.add(Address.fromJson(record.data));
    } catch (e) {
      print('Error adding address: $e');
    }
  }

  /// Retrieve a single address by ID
  Future<Address?> getOneAddress(String id) async {
    try {
      final record = await dataBase.pb.collection('address').getOne(id);
      return Address.fromJson(record.data);
    } catch (e) {
      print('Error fetching address with ID $id: $e');
      return null; // Return null to avoid crashes
    }
  }

  Future<List<Address>> getAddressesByUserId(String userId) async {
    try {
      final records = await dataBase.pb.collection('address').getList(
            filter: 'id_user ?~ "$userId"', // Dùng `?~` để kiểm tra trong mảng
          );
      return records.items
          .map((record) => Address.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      return []; // Trả về danh sách rỗng để tránh crash ứng dụng
    }
  }
}
