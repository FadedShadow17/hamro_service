import 'package:flutter/material.dart';
import 'package:hamro_service/screens/login_screen.dart';
import 'package:hamro_service/screens/role_screen.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),

        // Main image card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/image3.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.build, size: 100, color: Colors.grey),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Find trusted experts\nnear you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Description
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Verified local technicians ready\nto serve.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
          ),
        ),

        const Spacer(),

        // LOGIN button
        Padding(
          padding: const EdgeInsets.only(right: 24, bottom: 32),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 120,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const RoleScreen(),
                      ),
                    );
                  },
                  child: const Center(
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
