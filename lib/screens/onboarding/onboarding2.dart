import 'package:flutter/material.dart';

class Onboarding2 extends StatelessWidget {
  final VoidCallback? onNext;
  
  const Onboarding2({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),

        // Main image card with teal green background
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF1ABC9C), // Teal green
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
              'assets/images/image2.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.smartphone,
                    size: 100,
                    color: Colors.white,
                  ),
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
            'Easy booking, clear\npricing.',
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
            'Simple bookings with fully\ntransparent rates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),

        const Spacer(),

        // NEXT button
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
                  onTap: onNext,
                  child: const Center(
                    child: Text(
                      'NEXT',
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

