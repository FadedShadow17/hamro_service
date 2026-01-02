import 'package:flutter/material.dart';
import 'package:hamro_service/bottom_navigation/favorites.dart';
import 'package:hamro_service/bottom_navigation/payment.dart';
import 'package:hamro_service/bottom_navigation/home.dart';
import 'package:hamro_service/features/profile/presentation/pages/profile_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const FavoritesScreen(),
    const PaymentScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Hide AppBar when Profile tab is selected (index 3)
    final bool showAppBar = _selectedIndex != 3;
    
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              elevation: 0,
              backgroundColor: const Color.fromARGB(
                255,
                230,
                229,
                231,
              ), 
              title: const Text(
                "Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            )
          : null,

      body: lstBottomScreen[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payment"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        backgroundColor: Colors.black,
        selectedItemColor: Colors.lightGreen,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
