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

  Future<void> updateAddress(Address address) async {
    try {
      // Send the updated address to Firestore (or other backend)
      final updatedAddress = await dataBase.pb.collection('address').update(
        address.id,
        body: {
          'type': address.type,
          'id_user': address.id_user,
          'street': address.street,
          'city': address.city,
          'state': address.state,
          'updated': address.updated.toIso8601String(),
        },
      );

      // Check for a null response, throw if necessary
      if (updatedAddress == null) {
        throw Exception("Failed to update address: No response from server");
      }

      // Optionally, return or log the successful update
      print("Address updated successfully: ${updatedAddress.id}");
    } catch (e) {
      // Handle the error
      print('Error updating address: $e');
      rethrow; // Optionally rethrow to propagate the error to the caller
    }
  }
}
