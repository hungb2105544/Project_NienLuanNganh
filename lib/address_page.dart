import 'package:flutter/material.dart';
import 'package:project/add_address_page.dart';
import 'package:project/auth_service.dart';
import 'package:project/information_address_page.dart';
import 'package:project/model/address/address.dart';
import 'package:project/model/address/address_manager.dart';
import 'package:project/model/user/user.dart';
import 'package:provider/provider.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final AddressManager addressManager = AddressManager();
  List<Address> addresses = [];

  Future<void> _fetchAddresses(User user) async {
    List<Address> fetchedAddresses =
        await addressManager.getAddressesByUserId(user.id.toString());
    setState(() {
      addresses = fetchedAddresses;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthService authService =
          Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user != null) {
        _fetchAddresses(user);
      } else {
        debugPrint("User is null!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Addresses"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: addresses.isEmpty
              ? const Center(
                  child: Text(
                    "No addresses found!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    return AddressItem(
                      address: addresses[index],
                      onAddressUpdated: (updatedAddress) {
                        setState(() {
                          addresses[index] = updatedAddress;
                        });
                      },
                      onAddressDeleted: () {
                        setState(() {
                          addresses.removeAt(index);
                        });
                      },
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAddressPage(),
            ),
          ).then((newAddress) {
            if (newAddress != null) {
              print("New Address Added: ${newAddress.id}");
              setState(() {
                addresses.add(newAddress);
              });
            }
          });
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddressItem extends StatelessWidget {
  const AddressItem({
    super.key,
    required this.address,
    required this.onAddressUpdated,
    required this.onAddressDeleted,
  });

  final Address address;
  final Function(Address updatedAddress) onAddressUpdated;
  final VoidCallback onAddressDeleted;

  Future<void> _deleteAddress(BuildContext context) async {
    final AddressManager addressManager = AddressManager();
    try {
      await addressManager.deleteAddress(address.id);
      print("Address deleted: ${address.id}"); // Kiểm tra ID bị xóa
      onAddressDeleted();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete address: $e')),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Confirm Delete',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Are you sure you want to delete this address?\n"${address.street}, ${address.city}, ${address.state}"',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black12, width: 1.5),
        ),
        tileColor: Colors.white,
        leading: const Icon(Icons.location_on, size: 36, color: Colors.black),
        title: Text(
          address.type,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${address.street}, ${address.city}, ${address.state}',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 24),
              onPressed: () async {
                bool? confirmDelete =
                    await _showDeleteConfirmationDialog(context);
                if (confirmDelete == true) {
                  await _deleteAddress(context);
                }
              },
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.black54),
          ],
        ),
        onTap: () async {
          final updatedAddress = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InformationAddressPage(address: address),
            ),
          );

          if (updatedAddress != null) {
            onAddressUpdated(updatedAddress);
          }
        },
      ),
    );
  }
}
