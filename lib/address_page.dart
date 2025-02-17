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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Page'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: addresses.isEmpty
              ? Center(child: Text('No address found!'))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    return AddressItem(
                      address: addresses[index],
                      onAddressUpdated: (updatedAddress) {
                        setState(() {
                          // Update the address in the list after editing
                          addresses[index] = updatedAddress;
                        });
                      },
                    );
                  },
                ),
        ),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.receipt_long_outlined, size: 40),
          title: Text(
            address.type,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${address.street}, ${address.city}, ${address.state}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            // Navigate to the information address page
            final updatedAddress = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InformationAddressPage(address: address),
              ),
            );

            if (updatedAddress != null) {
              // When the address is updated, update it in the list
              onAddressUpdated(updatedAddress);
            }
          },
        ),
      ),
    );
  }
}
