import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:project/home.dart';

class SlpashSrceen extends StatelessWidget {
  const SlpashSrceen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Get.offAll(() => Home());
    });
    return const Scaffold(
      body: Center(
        child: Column(
          children: [
            Image(
              image: AssetImage('assets/iamges/logo.png'),
            ),
            Text(
              "Luxury Lane",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}
