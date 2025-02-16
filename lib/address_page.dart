import 'package:flutter/material.dart';
import 'package:project/model/address/address.dart';
import 'package:project/model/address/address_manager.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final AddressManager addressManager = AddressManager();
  List<Address> address = [];

  void _fetchAddresses() async {
    await addressManager.fetchAddresses();
    setState(() {
      address = addressManager.addresses;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Page'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: address.length,
              itemBuilder: (context, index) {
                return AddressItem(address: address[index]);
              },
            ),
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
  });
  final Address address;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
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
            '${address.street},${address.city},${address.state}', // Giả sử order.date là một String
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => AddressInformationPage(
            //            address: address,
            //           )),
            // )
          },
        ),
      ),
    );
  }
}
