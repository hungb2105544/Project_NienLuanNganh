import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/model/address/address.dart';
import 'package:project/model/address/address_manager.dart';
import 'package:provider/provider.dart';

class InformationAddressPage extends StatefulWidget {
  const InformationAddressPage({super.key, required this.address});

  final Address address;

  @override
  State<InformationAddressPage> createState() => _InformationAddressPageState();
}

class _InformationAddressPageState extends State<InformationAddressPage> {
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _streetController.text = widget.address.street;
    _cityController.text = widget.address.city;
    _stateController.text = widget.address.state;
    _typeController.text = widget.address.type;
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _updateInformationAddress() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    Address updatedAddress = Address(
      id: widget.address.id,
      type: _typeController.text,
      id_user: [user.id],
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      updated: DateTime.now(),
    );

    try {
      AddressManager addressManager = AddressManager();
      await addressManager.updateAddress(updatedAddress);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address updated successfully!')),
      );

      Navigator.pop(context, updatedAddress); // Return updated address
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update address: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Information Address"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Street", _streetController),
              _buildTextField("City", _cityController),
              _buildTextField("State", _stateController),
              _buildTextField("Type", _typeController),
              const SizedBox(height: 20),
              _buildButton(
                text: "Update",
                onPressed: _isLoading ? null : _updateInformationAddress,
                color: Colors.blue[300]!,
              ),
              const SizedBox(height: 10),
              _buildButton(
                text: "Back",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    Color color = Colors.black,
    Color textColor = Colors.white,
    bool isOutlined = false,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          boxShadow: [
            if (!isOutlined)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(1, 3),
              ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutlined ? Colors.white : color,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: isOutlined
                  ? const BorderSide(color: Colors.black, width: 2)
                  : BorderSide.none,
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOutlined ? Colors.black : textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
