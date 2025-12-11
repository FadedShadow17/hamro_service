import 'package:flutter/material.dart';
import 'package:hamro_service/screens/onboarding/onboarding_screen.dart';

class IconScreen extends StatelessWidget {
  const IconScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Text(
              'Welcome to',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9AA3B1),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: 200,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/icon.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image, size: 80, color: Colors.grey),
                  );
                },
              ),
            ),

            const SizedBox(height: 48),

            const Text(
              'Hamro Service App',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                letterSpacing: 0.3,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Book home services in\nKathmandu in minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7C8796),
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 60, left: 40, right: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Material(
                  color: const Color(0xFF34C759),
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const OnboardingScreen(),
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        'START',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
