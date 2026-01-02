import 'package:flutter/material.dart';

class Onboarding2 extends StatelessWidget {
  final VoidCallback? onNext;

  const Onboarding2({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          Container(
            width: double.infinity,
            height: 280,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/image2.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.smartphone,
                      size: 100,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 40),

          Text(
            'Easy booking, clear\npricing.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
          ),

          const SizedBox(height: 16),

          Text(
            'Simple bookings with fully\ntransparent rates.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 16,
                  height: 1.4,
                ),
          ),

          const SizedBox(height: 40),

          if (onNext != null)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 120,
                height: 56,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
