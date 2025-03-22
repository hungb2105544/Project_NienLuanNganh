import 'package:flutter/material.dart';
import 'package:project/login.dart';
import 'package:project/model/favorite_product/favorite_product_manager.dart';
import 'package:project/model/product/product_manager.dart';
import 'package:project/model/promotion/promotion_manager.dart';
import 'package:project/model/promotion_user/promotion_user_manager.dart';
import 'package:provider/provider.dart';
import 'package:project/auth_service.dart';
import 'package:project/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  try {
    await authService.initialize();
  } catch (e) {
    debugPrint("Lỗi khi khởi tạo AuthService: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PromotionUserManager()),
        ChangeNotifierProvider(create: (_) => PromotionManager()),
        ChangeNotifierProvider(create: (_) => ProductManager()),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(create: (_) => FavoriteProductManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final nextScreen =
          authService.isLoggedIn ? const HomeScreen() : const Login();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      debugPrint("Lỗi khi xác định màn hình tiếp theo: $e");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
