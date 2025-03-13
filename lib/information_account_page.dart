// import 'package:flutter/material.dart';
// import 'package:project/auth_service.dart';
// import 'package:project/model/user/user.dart';
// import 'package:provider/provider.dart';

// class InformationAccountPage extends StatefulWidget {
//   const InformationAccountPage({super.key});

//   @override
//   State<InformationAccountPage> createState() => _InformationAccountPageState();
// }

// class _InformationAccountPageState extends State<InformationAccountPage> {
//   late TextEditingController _nameController = TextEditingController();
//   late TextEditingController _emailController = TextEditingController();
//   late TextEditingController _phoneController = TextEditingController();
//   late TextEditingController _fullNameController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final AuthService authService =
//           Provider.of<AuthService>(context, listen: false);
//       final user = authService.currentUser;

//       if (user != null) {
//         _nameController.text = user.name;
//         _emailController.text = user.email;
//         _phoneController.text = user.phone;
//         _fullNameController.text = user.fullname;
//       }
//     });
//   }

//   Future<void> _updateUserInfo() async {
//     final AuthService authService =
//         Provider.of<AuthService>(context, listen: false);
//     final user = authService.currentUser;

//     if (user == null) return;

//     setState(() => _isLoading = true);

//     User updateUser = User(
//       id: user.id,
//       name: _nameController.text,
//       email: _emailController.text,
//       phone: _phoneController.text,
//       fullname: _fullNameController.text,
//       // avatar: avatarUrl ?? user.avatar,
//       created: user.created,
//       updated: DateTime.now(),
//     );

//     try {
//       await authService.updateUserInfo(updateUser);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update user information: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AuthService authService = Provider.of<AuthService>(context);
//     final user = authService.currentUser;

//     if (user == null) {
//       return Center(child: Text('No user logged in'));
//     }

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(25.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Information Account',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 20),
//                   _buildTextField("Name", _nameController),
//                   SizedBox(height: 20),
//                   _buildTextField("Full Name", _fullNameController),
//                   SizedBox(height: 20),
//                   _buildTextField("Email", _emailController),
//                   SizedBox(height: 20),
//                   _buildTextField("Number Phone", _phoneController),
//                   SizedBox(height: 20),
//                   Container(
//                     width: double.infinity,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withAlpha((0.2 * 255).toInt()),
//                           blurRadius: 6,
//                           offset: Offset(1, 3),
//                         ),
//                       ],
//                     ),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5.0),
//                           side: BorderSide(color: Colors.black, width: 2),
//                         ),
//                         backgroundColor: Colors.white,
//                       ),
//                       onPressed: _isLoading
//                           ? null
//                           : () async {
//                               await _updateUserInfo(); // Đợi cập nhật xong
//                               Navigator.pop(context); // Quay lại màn hình trước
//                             },
//                       child:
//                           Text("Update", style: TextStyle(color: Colors.black)),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     width: double.infinity,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withAlpha((0.2 * 255).toInt()),
//                           blurRadius: 6,
//                           offset: Offset(1, 3),
//                         ),
//                       ],
//                     ),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5.0),
//                           side: BorderSide(color: Colors.black, width: 2),
//                         ),
//                         backgroundColor: Colors.white,
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context); // Quay lại
//                       },
//                       child:
//                           Text("Back", style: TextStyle(color: Colors.black)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             border: Border.all(color: Colors.black, width: 2),
//           ),
//           child: TextField(
//             controller: controller,
//             decoration: InputDecoration(
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.all(10),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
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
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _fullNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    _nameController = TextEditingController(text: user?.name ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _phoneController = TextEditingController(text: user?.phone ?? "");
    _fullNameController = TextEditingController(text: user?.fullname ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _updateUserInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await authService.updateUserInfo(
        User(
          id: user.id,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          fullname: _fullNameController.text,
          created: user.created,
          updated: DateTime.now(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information updated successfully!')),
      );

      Navigator.pop(context); // Quay lại màn hình trước
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
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Information Account"),
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
              _buildTextField("Name", _nameController),
              _buildTextField("Full Name", _fullNameController),
              _buildTextField("Email", _emailController),
              _buildTextField("Number Phone", _phoneController),
              const SizedBox(height: 20),
              _buildButton(
                text: "Update",
                onPressed: _isLoading ? null : _updateUserInfo,
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

  // Widget _buildButton(
  //     {required String text, required VoidCallback? onPressed}) {
  //   return SizedBox(
  //     width: double.infinity,
  //     height: 50,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: Colors.white,
  //         foregroundColor: Colors.black,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(5.0),
  //           side: const BorderSide(color: Colors.black, width: 2),
  //         ),
  //       ),
  //       onPressed: onPressed,
  //       child: Text(text,
  //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //     ),
  //   );
  // }
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
