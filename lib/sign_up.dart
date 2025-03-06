import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/component/error_message.dart';
import 'package:project/component/text_field.dart';
import 'package:project/home_screen.dart';
import 'package:project/model/cart/cart_manager.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool _isSubmitting = false;

  Future<void> _signUp() async {
    if (_isSubmitting) return;

    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ email và mật khẩu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu phải có ít nhất 8 ký tự'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu và xác nhận mật khẩu không khớp'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthService>().register(
            _emailController.text,
            _passwordController.text,
            _passwordConfirmController.text,
          );

      await context.read<AuthService>().login(
            _emailController.text,
            _passwordController.text,
          );

      // Tạo giỏ hàng mới cho user
      final cartManager = CartManager();
      await cartManager.createNewCart(_emailController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công và giỏ hàng đã được tạo!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      String errorMessage = 'Đăng ký thất bại. Vui lòng thử lại.';
      if (e.toString().contains('validation_required')) {
        errorMessage = 'Vui lòng nhập đầy đủ thông tin.';
      } else if (e.toString().contains('validation_invalid_email')) {
        errorMessage = 'Email không hợp lệ.';
      } else if (e.toString().contains('validation_length_out_of_range')) {
        errorMessage = 'Mật khẩu phải có ít nhất 8 ký tự.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    color: Colors.black,
                  ),
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
          const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          TextFieldUser(
            hintText: 'Email',
            controllerUser: _emailController,
          ),
          const SizedBox(height: 15),
          TextFieldPassword(
            controllerPassword: _passwordController,
            hintText: "Password",
          ),
          const SizedBox(height: 15),
          TextFieldPassword(
            controllerPassword: _passwordConfirmController,
            hintText: "Confirm Password",
          ),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
              ),
              onPressed: _isSubmitting ? null : _signUp,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 15),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }
}
