// import 'package:flutter/material.dart';
// import 'package:project/auth_service.dart';
// import 'package:project/information_account_page.dart';
// import 'package:project/login.dart';
// import 'package:project/sign_up.dart';
// import 'package:provider/provider.dart';

// class AccountPage extends StatefulWidget {
//   const AccountPage({super.key});

//   @override
//   State<AccountPage> createState() => _AccountPageState();
// }

// class _AccountPageState extends State<AccountPage> {
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final authService = Provider.of<AuthService>(context);
//     final user = authService.currentUser;
//     return user != null
//         ? Scaffold(
//             body: Center(
//               child: Container(
//                 margin: EdgeInsets.only(top: screenWidth * 0.20),
//                 child: Column(
//                   children: [
//                     // Container(
//                     //   width: screenWidth * 0.27,
//                     //   height: screenWidth * 0.27,
//                     //   decoration: BoxDecoration(
//                     //     shape: BoxShape.circle,
//                     //     border: Border.all(
//                     //       color: const Color.fromARGB(255, 0, 0, 0),
//                     //       width: 3,
//                     //       strokeAlign: BorderSide.strokeAlignOutside,
//                     //     ),
//                     //   ),
//                     //   child: ClipRRect(
//                     //     borderRadius: BorderRadius.circular(100),
//                     //     child: Image.network(
//                     //       'http://10.0.2.2:8090/api/files/_pb_users_auth_/${user.id}/${user.avatar}',
//                     //       width: screenWidth * 0.25,
//                     //       height: screenWidth * 0.25,
//                     //       fit: BoxFit.cover,
//                     //     ),
//                     //   ),
//                     // ),
//                     const SizedBox(height: 20),
//                     Column(
//                       children: [
//                         Text(
//                           "Welcome to Luxury Lare store",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 25,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           user.name,
//                           style: TextStyle(
//                             color: const Color.fromARGB(255, 49, 130, 53),
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 25),
//                     Column(
//                       spacing: screenWidth * 0.05,
//                       children: [
//                         OptionForAccount(
//                           title: "Orders",
//                           icon: Icons.list_alt,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       InformationAccountPage()),
//                             );
//                           },
//                         ),
//                         OptionForAccount(
//                           title: "Information",
//                           icon: Icons.person,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       InformationAccountPage()),
//                             );
//                           },
//                         ),
//                         OptionForAccount(
//                           title: "Address",
//                           icon: Icons.location_on,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       InformationAccountPage()),
//                             );
//                           },
//                         ),
//                         OptionForAccount(
//                           title: "Settings",
//                           icon: Icons.settings,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       InformationAccountPage()),
//                             );
//                           },
//                         ),
//                         OptionForAccount(
//                           title: "Help",
//                           icon: Icons.help_outline,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       InformationAccountPage()),
//                             );
//                           },
//                         ),
//                         SizedBox(
//                           height: screenWidth * 0.10,
//                           width: screenWidth * 0.90,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               authService.logout();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 10), // Kích thước nhỏ hơn
//                               backgroundColor: Colors.white, // Màu nền trắng
//                               foregroundColor: Colors.black, // Màu chữ đen
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                     5), // Bo góc nhẹ (5px)
//                                 side: const BorderSide(
//                                     color: Colors.black, width: 2), // Viền đen
//                               ),
//                               elevation: 2, // Hiệu ứng nổi nhẹ
//                             ),
//                             child: const Text(
//                               'Logout',
//                               style: TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           )
//         : Scaffold(
//             body: Center(
//               child: Container(
//                 margin: EdgeInsets.only(top: screenWidth * 0.20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 25),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "You are not logged in",
//                           textAlign: TextAlign.start,
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => Login()),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 10), // Kích thước nhỏ hơn
//                               backgroundColor: Colors.black, // Màu nền đen
//                               foregroundColor: Colors.white, // Màu chữ trắng
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                     5), // Bo góc nhẹ (5px)
//                               ),
//                               elevation: 2, // Hiệu ứng nổi nhẹ
//                             ),
//                             child: const Text(
//                               'Login',
//                               style: TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                           const SizedBox(width: 15), // Khoảng cách giữa hai nút
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => SignUp()),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 10), // Kích thước nhỏ hơn
//                               backgroundColor: Colors.white, // Màu nền trắng
//                               foregroundColor: Colors.black, // Màu chữ đen
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                     5), // Bo góc nhẹ (5px)
//                                 side: const BorderSide(
//                                     color: Colors.black, width: 2), // Viền đen
//                               ),
//                               elevation: 2, // Hiệu ứng nổi nhẹ
//                             ),
//                             child: const Text(
//                               'Register',
//                               style: TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       spacing: screenWidth * 0.05,
//                       children: [
//                         OptionForAccount(
//                           title: "Settings",
//                           icon: Icons.settings,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       InformationAccountPage()),
//                             );
//                           },
//                         ),
//                         OptionForAccount(
//                           title: "Help",
//                           icon: Icons.help_outline,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       InformationAccountPage()),
//                             );
//                           },
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//   }
// }

// class OptionForAccount extends StatelessWidget {
//   const OptionForAccount({
//     super.key,
//     required this.title,
//     required this.icon,
//     required this.onPressed,
//   });

//   final String title;
//   final IconData icon;
//   final VoidCallback onPressed; // Đổi từ Widget thành Function()

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final buttonSize = screenWidth * 0.90; // 90% chiều rộng màn hình

//     return SizedBox(
//       width: buttonSize,
//       height: 55, // Giữ nguyên kích thước nút
//       child: Material(
//         color: Colors.white, // Màu nền trắng
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5), // Bo góc nhẹ
//           side: const BorderSide(color: Colors.black, width: 2), // Viền đen 2px
//         ),
//         elevation: 3, // Hiệu ứng nổi nhẹ
//         child: InkWell(
//           onTap: onPressed, // Gọi trực tiếp hàm onPressed()
//           borderRadius: BorderRadius.circular(5),
//           splashColor: Colors.black.withAlpha(50), // Hiệu ứng gợn sóng đen nhạt
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(left: 20),
//                 child: Icon(icon,
//                     color: Colors.black, size: 22), // Giảm kích thước icon
//               ),
//               Container(
//                 margin: const EdgeInsets.only(left: 15),
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 16, // Giữ nguyên size chữ
//                     fontWeight: FontWeight.w600, // Làm chữ tinh tế hơn
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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
