import 'package:flutter/material.dart';
import 'package:project/address_page.dart';
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
      appBar: AppBar(
        title: const Text("Account"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Avatar + Welcome Text
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black12,
                child: Icon(
                  user != null ? Icons.person : Icons.person_outline,
                  size: 50,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                user != null
                    ? "Welcome, ${user.name}!"
                    : "You are not logged in",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // If User is Logged In
              if (user != null) ...[
                OptionForAccount(
                  title: "Orders",
                  icon: Icons.list_alt,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OrderPage()));
                  },
                ),
                OptionForAccount(
                  title: "Information",
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationAccountPage()));
                  },
                ),
                OptionForAccount(
                  title: "Address",
                  icon: Icons.location_on,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddressPage()));
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    authService.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: Size(screenWidth * 0.90, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _authButton(
                      text: 'Login',
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                    ),
                    const SizedBox(width: 15),
                    _authButton(
                      text: 'Register',
                      color: Colors.white,
                      textColor: Colors.black,
                      borderColor: Colors.black,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
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
                            builder: (context) => InformationAccountPage()));
                  },
                ),
                OptionForAccount(
                  title: "Help",
                  icon: Icons.help_outline,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InformationAccountPage()));
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _authButton({
    required String text,
    required Color color,
    required Color textColor,
    VoidCallback? onPressed,
    Color? borderColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black12, width: 1),
        ),
        tileColor: Colors.white,
        leading: Icon(icon, color: Colors.black, size: 24),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 18, color: Colors.black54),
      ),
    );
  }
}
