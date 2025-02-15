import 'package:flutter/material.dart';

class LoveButton extends StatefulWidget {
  const LoveButton({super.key});

  @override
  State<LoveButton> createState() => _LoveButtonState();
}

class _LoveButtonState extends State<LoveButton> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    return (isClick)
        ? IconButton(
            onPressed: () {
              setState(() {
                isClick = !isClick;
              });
              print('${MediaQuery.of(context).size.height}');
            },
            icon: ClipOval(
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(124, 187, 187, 187),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/heart.png'),
                ),
              ),
            ),
          )
        : IconButton(
            onPressed: () {
              setState(() {
                isClick = !isClick;
              });
            },
            icon: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(124, 187, 187, 187),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                height: 40,
                width: 40,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/heart_outline.png'),
                ),
              ),
            ),
          );
  }
}
