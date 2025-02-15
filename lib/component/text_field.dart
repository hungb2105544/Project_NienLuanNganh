import 'package:flutter/material.dart';

class TextFieldUser extends StatefulWidget {
  const TextFieldUser(
      {super.key, required this.hintText, required this.controllerUser});
  final String hintText;
  final TextEditingController controllerUser;
  @override
  State<TextFieldUser> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldUser> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: TextField(
          controller: widget.controllerUser,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.person),
              hintText: widget.hintText,
              alignLabelWithHint: true),
        ),
      ),
    );
  }
}

class TextFieldPassword extends StatefulWidget {
  const TextFieldPassword(
      {super.key, required this.controllerPassword, required this.hintText});

  final String hintText;
  final TextEditingController controllerPassword;
  @override
  State<TextFieldPassword> createState() => _TextFieldPasswordState();
}

class _TextFieldPasswordState extends State<TextFieldPassword> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: TextField(
          controller: widget.controllerPassword,
          textAlignVertical: TextAlignVertical.center,
          obscuringCharacter: '*',
          keyboardType: TextInputType.visiblePassword,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: const Color.fromARGB(255, 8, 8, 8),
            ),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.lock),
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: Icon((isObscure)
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => {
                setState(() {
                  isObscure = !isObscure;
                })
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TextFieldConfirmPassword extends StatefulWidget {
  const TextFieldConfirmPassword(
      {super.key, required this.controllerConfirmPassword});
  final TextEditingController controllerConfirmPassword;
  @override
  State<TextFieldConfirmPassword> createState() =>
      _TextFieldConfirmPasswordState();
}

class _TextFieldConfirmPasswordState extends State<TextFieldConfirmPassword> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: TextField(
          controller: widget.controllerConfirmPassword,
          textAlignVertical: TextAlignVertical.center,
          obscuringCharacter: '*',
          keyboardType: TextInputType.visiblePassword,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: const Color.fromARGB(255, 8, 8, 8),
            ),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.lock),
            hintText: 'Comfirm Password',
            suffixIcon: IconButton(
              icon: Icon((isObscure)
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => {
                setState(() {
                  isObscure = !isObscure;
                })
              },
            ),
          ),
        ),
      ),
    );
  }
}
