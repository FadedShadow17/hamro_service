import 'package:flutter/material.dart';
import 'package:hamro_service/bottom_navigation/about.dart';
import 'package:hamro_service/bottom_navigation/cart.dart';
import 'package:hamro_service/bottom_navigation/home.dart';
import 'package:hamro_service/bottom_navigation/profile.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<Dashboard> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const Home(),
    const Cart(),
    const Profile(),
    const About(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.album_outlined),
            label: "About",
          ),
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
