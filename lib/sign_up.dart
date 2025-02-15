import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project/component/error_message.dart';
import 'package:project/component/text_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  void _signUp() {
    // Logic đăng ký
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nền mờ trắng đen
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation, // Giảm màu sắc, giữ lại độ sáng
              ),
              child: Image.asset(
                "assets/images/backgroundlogin.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 4),
              child:
                  Container(color: Colors.black.withAlpha((0.2 * 255).toInt())),
            ),
          ),

          // Nội dung chính
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('assets/images/logo.png',
                      width: 150, color: Colors.black),
                  const SizedBox(height: 20),
                  _buildSignUpForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Colors.white.withAlpha((0.85 * 255).toInt()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            spreadRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sign Up',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 20),

          // Username
          TextFieldUser(hintText: 'Username', controllerUser: _userController),
          const SizedBox(height: 15),

          // Password
          TextFieldPassword(
              controllerPassword: _passwordController, hintText: "Password"),
          const SizedBox(height: 10),

          // Confirm Password
          TextFieldPassword(
              controllerPassword: _passwordConfirmController,
              hintText: "Confirm Password"),

          // Kiểm tra lỗi mật khẩu
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _passwordConfirmController,
            builder: (context, value, child) {
              return ErrorMessage(
                password: _passwordController.text,
                confirmPassword: _passwordConfirmController.text,
              );
            },
          ),

          const SizedBox(height: 15),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 6,
              ),
              onPressed: _signUp,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Sign Up',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Điều hướng về đăng nhập
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Already have an account? Login',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
