import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
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
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
  });

  final Address address;
  final Function(Address updatedAddress) onAddressUpdated;

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
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 18, color: Colors.black54),
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
