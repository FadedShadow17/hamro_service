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
    return Scaffold(
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
