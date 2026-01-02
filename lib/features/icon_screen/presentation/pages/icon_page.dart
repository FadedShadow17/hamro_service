import 'package:flutter/material.dart';
import 'package:hamro_service/features/onboarding/presentation/pages/onboarding_screen.dart';

class IconPage extends StatelessWidget {
  const IconPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 60),

                Text(
                  'Welcome to',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: 200,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icons/icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 48),

                Text(
                  'Hamro Service App',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Book home services in\nKathmandu in minutes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                ),

                const SizedBox(height: 60),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const OnboardingPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'START',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
    );
  }
}
