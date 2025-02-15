import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/model/user/user.dart';
import 'package:provider/provider.dart';

class InformationAccountPage extends StatefulWidget {
  const InformationAccountPage({super.key});

  @override
  State<InformationAccountPage> createState() => _InformationAccountPageState();
}

class _InformationAccountPageState extends State<InformationAccountPage> {
  // File? _selectedImage;
  // final ImagePicker _picker = ImagePicker();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  late TextEditingController _fullNameController = TextEditingController();
  bool _isLoading = false; // Trạng thái loading khi cập nhật

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthService authService =
          Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _fullNameController.text = user.fullname;
      }
    });
  }

  // Future<void> _pickImage() async {
  //   final XFile? pickedFile =
  //       await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImage = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> _updateUserInfo() async {
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    // String? avatarUrl = user.avatar;

    // if (_selectedImage != null) {
    //   try {
    //     avatarUrl = await authService.uploadImage(_selectedImage!, user.id);
    //   } catch (e) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Failed to upload image: $e')),
    //     );
    //     setState(() => _isLoading = false);
    //     return;
    //   }
    // }

    User updateUser = User(
      id: user.id,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      fullname: _fullNameController.text,
      // avatar: avatarUrl ?? user.avatar,
      created: user.created,
      updated: DateTime.now(),
    );

    try {
      await authService.updateUserInfo(updateUser);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user information: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return Center(child: Text('No user logged in'));
    }

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
                    'Information Account',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildTextField("Name", _nameController),
                  SizedBox(height: 20),
                  _buildTextField("Full Name", _fullNameController),
                  SizedBox(height: 20),
                  _buildTextField("Email", _emailController),
                  SizedBox(height: 20),
                  _buildTextField("Number Phone", _phoneController),
                  SizedBox(height: 20),
                  Container(
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
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await _updateUserInfo(); // Đợi cập nhật xong
                              Navigator.pop(context); // Quay lại màn hình trước
                            },
                      child:
                          Text("Update", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
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
                      onPressed: () {
                        Navigator.pop(context); // Quay lại
                      },
                      child:
                          Text("Back", style: TextStyle(color: Colors.black)),
                    ),
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
}
