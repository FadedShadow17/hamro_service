import 'package:flutter/material.dart';
import 'package:hamro_service/features/favorites/presentation/pages/favorites_page.dart';
import 'package:hamro_service/features/payment/presentation/pages/payment_page.dart';
import 'package:hamro_service/features/home/presentation/pages/home_page.dart';
import 'package:hamro_service/features/cart/presentation/pages/cart_page.dart';
import 'package:hamro_service/features/profile/presentation/pages/profile_page.dart';
import 'package:hamro_service/core/widgets/modern_bottom_nav.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = [
    const HomePage(),
    const FavoritesPage(),
    const CartPage(),
    const PaymentPage(),
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
