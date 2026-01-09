import 'package:flutter/material.dart';
import 'package:hamro_service/bottom_navigation/favorites.dart';
import 'package:hamro_service/bottom_navigation/payment.dart';
import 'package:hamro_service/bottom_navigation/home.dart';
import 'package:hamro_service/features/profile/presentation/pages/profile_page.dart';
import 'package:hamro_service/core/widgets/modern_bottom_nav.dart';

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

      bottomNavigationBar: ModernBottomNav(
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
