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
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streetController.text = widget.address.street;
      _cityController.text = widget.address.city;
      _stateController.text = widget.address.state;
      _typeController.text = widget.address.type;
    });
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
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    Address updatedAddress = Address(
      id: widget.address.id,
      type: _typeController.text,
      id_user: [user.id], // Ensure idUser matches your model
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      updated: DateTime.now(),
    );

    try {
      AddressManager addressManager = AddressManager();
      await addressManager.updateAddress(updatedAddress);
      if (mounted) {
        Navigator.pop(context, updatedAddress); // Return updated address
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update address: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Information Address',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildTextField("Street", _streetController),
                  SizedBox(height: 20),
                  _buildTextField("City", _cityController),
                  SizedBox(height: 20),
                  _buildTextField("State", _stateController),
                  SizedBox(height: 20),
                  _buildTextField("Type", _typeController),
                  SizedBox(height: 20),
                  _buildButton(
                    "Update",
                    _isLoading ? null : _updateInformationAddress,
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 10),
                  _buildButton(
                    "Back",
                    () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed,
      {bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 6,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(color: Colors.black, width: 2),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: isLoading
            ? CircularProgressIndicator(color: Colors.black)
            : Text(text, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
