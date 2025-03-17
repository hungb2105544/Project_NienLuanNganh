// import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:project/account_page.dart';
// import 'package:project/address_page.dart';
// import 'package:project/home.dart';

// enum _SelectedTab { home, favorite, add, search, person }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   var _selectedTab = _SelectedTab.home;
//   void _handleIndexChanged(int i) {
//     setState(() {
//       _selectedTab = _SelectedTab.values[i];
//     });
//   }

//   final List<Widget> _pages = <Widget>[
//     Home(),
//     Home(),
//     Home(),
//     Home(),
//     AccountPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.white,
//         ),
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: Scaffold(
//         extendBody: true,
//         bottomNavigationBar: CrystalNavigationBar(
//           onTap: _handleIndexChanged,
//           currentIndex: _SelectedTab.values.indexOf(_selectedTab),
//           height: 60,
//           unselectedItemColor: Colors.white,
//           backgroundColor: const Color.fromARGB(40, 0, 0, 0),
//           items: [
//             /// Home
//             CrystalNavigationBarItem(
//               icon: Icons.home,
//               unselectedIcon: Icons.home_outlined,
//               selectedColor: const Color.fromARGB(255, 0, 0, 0),
//             ),

//             /// Favourite
//             CrystalNavigationBarItem(
//               icon: Icons.favorite,
//               unselectedIcon: Icons.favorite_border,
//               selectedColor: Colors.red,
//             ),

//             CrystalNavigationBarItem(
//                 icon: Icons.assignment,
//                 unselectedIcon: Icons.assignment_outlined,
//                 selectedColor: Colors.white),

//             CrystalNavigationBarItem(
//                 icon: Icons.support_agent,
//                 unselectedIcon: Icons.support_agent_outlined,
//                 selectedColor: Colors.white),

//             /// Profile
//             CrystalNavigationBarItem(
//               icon: Icons.person,
//               unselectedIcon: Icons.person_2_outlined,
//               selectedColor: Colors.white,
//             ),
//           ],
//         ),
//         body: _pages[_SelectedTab.values.indexOf(_selectedTab)],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:project/account_page.dart';
import 'package:project/home.dart';

enum _SelectedTab { home, favorite, discount, person }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _selectedTab = _SelectedTab.home;

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
    });
  }

  final List<Widget> _pages = <Widget>[
    const Home(),
    const Home(),
    const Home(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        extendBody: true,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _SelectedTab.values.indexOf(_selectedTab),
          onTap: _handleIndexChanged,
          type: BottomNavigationBarType.fixed, // Hiển thị tất cả item kể cả > 3
          selectedItemColor: Colors.black, // Màu khi được chọn
          unselectedItemColor: Colors.grey, // Màu khi không chọn
          backgroundColor:
              const Color.fromARGB(240, 255, 255, 255), // Nền trắng mờ
          elevation: 10, // Độ nâng của thanh
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.discount_outlined),
              activeIcon: Icon(Icons.discount),
              label: 'Discount',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        body: _pages[_SelectedTab.values.indexOf(_selectedTab)],
      ),
    );
  }
}
