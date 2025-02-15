import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage(
      {super.key, required this.password, required this.confirmPassword});
  final String password;
  final String confirmPassword;
  @override
  Widget build(BuildContext context) {
    return (password != confirmPassword)
        ? Text(
            'Password and Confirm Password must be the same',
            style: TextStyle(
              color: Colors.red,
            ),
          )
        : Text('');
  }
}
