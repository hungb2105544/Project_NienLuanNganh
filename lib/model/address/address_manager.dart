import 'package:project/model/address/address.dart';
import 'package:project/model/database/pocketbase.dart';

class AddressManager {
  final DataBase dataBase = DataBase();

  final List<Address> _addresses = [];

  List<Address> get addresses => List.unmodifiable(_addresses);

  Future<void> fetchAddresses() async {
    try {
      final records = await dataBase.pb.collection('address').getFullList();
      _addresses.clear();
      _addresses.addAll(records.map((record) => Address.fromJson(record.data)));
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }

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

  Future<Address?> getOneAddress(String id) async {
    try {
      final record = await dataBase.pb.collection('address').getOne(id);
      return Address.fromJson(record.data);
    } catch (e) {
      print('Error fetching address with ID $id: $e');
      return null;
    }
  }

  Future<List<Address>> getAddressesByUserId(String userId) async {
    try {
      final records = await dataBase.pb.collection('address').getList(
            filter: 'id_user ?~ "$userId"',
          );
      return records.items
          .map((record) => Address.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final deletedAddress = await dataBase.pb.collection('address').delete(id);
      _addresses.removeWhere((address) => address.id == id);
      print("Address deleted successfully: $id");
    } catch (e) {
      print('Error deleting address: $e');
      rethrow;
    }
  }

  Future<Address?> getAddressCreated() async {
    try {
      final records = await dataBase.pb.collection('address').getFullList(
            sort: '-created',
          );

      if (records.isEmpty) {
        print("No addresses found.");
        return null;
      }

      print("Fetched Address: ${records.first}");
      return Address.fromJson(records.first.toJson());
    } catch (e) {
      print('Error fetching latest address: $e');
      return null;
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
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

      if (updatedAddress == null) {
        throw Exception("Failed to update address: No response from server");
      }

      print("Address updated successfully: ${updatedAddress.id}");
    } catch (e) {
      print('Error updating address: $e');
      rethrow;
    }
  }
}
