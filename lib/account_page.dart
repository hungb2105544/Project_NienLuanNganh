import 'package:flutter/material.dart';
import 'package:project/auth_service.dart';
import 'package:project/information_account_page.dart';
import 'package:project/login.dart';
import 'package:project/order_page.dart';
import 'package:project/sign_up.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Welcome Text
                Text(
                  user != null
                      ? "Welcome to Luxury Lare Store"
                      : "You are not logged in",
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // User Name (if logged in)
                if (user != null)
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 49, 130, 53),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 25),

                // If User is Logged In
                if (user != null) ...[
                  OptionForAccount(
                    title: "Orders",
                    icon: Icons.list_alt,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderPage()),
                      );
                    },
                  ),
                  OptionForAccount(
                    title: "Information",
                    icon: Icons.person,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationAccountPage()),
                      );
                    },
                  ),
                  OptionForAccount(
                    title: "Address",
                    icon: Icons.location_on,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationAccountPage()),
                      );
                    },
                  ),
                  OptionForAccount(
                    title: "Settings",
                    icon: Icons.settings,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationAccountPage()),
                      );
                    },
                  ),
                  OptionForAccount(
                    title: "Help",
                    icon: Icons.help_outline,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationAccountPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Logout Button
                  SizedBox(
                    height: screenWidth * 0.10,
                    width: screenWidth * 0.90,
                    child: ElevatedButton(
                      onPressed: () {
                        authService.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ] else ...[
                  // If User is Not Logged In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side:
                                const BorderSide(color: Colors.black, width: 2),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  OptionForAccount(
                    title: "Settings",
                    icon: Icons.settings,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationAccountPage()),
                      );
                    },
                  ),
                  OptionForAccount(
                    title: "Help",
                    icon: Icons.help_outline,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationAccountPage()),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionForAccount extends StatelessWidget {
  const OptionForAccount({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.90;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: buttonSize,
        height: 55,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          elevation: 3,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(5),
            splashColor: Colors.black.withAlpha(50),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Icon(icon, color: Colors.black, size: 22),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
