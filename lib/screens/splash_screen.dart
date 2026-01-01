import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hamro_service/screens/dashboard.dart';
import 'package:hamro_service/screens/icon_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Check authentication status
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Check if user is authenticated
    final authState = ref.read(authViewModelProvider);
    
    // If already authenticated, navigate to dashboard
    if (authState.isAuthenticated && authState.user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Dashboard(),
        ),
      );
    } else {
      // Check auth status (this will update state if user is logged in)
      await ref.read(authViewModelProvider.notifier).checkAuth();
      
      // Wait a bit for state to update
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      final updatedAuthState = ref.read(authViewModelProvider);
      
      // Navigate based on auth status
      if (updatedAuthState.isAuthenticated && updatedAuthState.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Dashboard(),
          ),
        );
      } else {
        // Not logged in, go to icon screen (which leads to onboarding/login)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const IconScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
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
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Text(
                    'Hamro Service App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.3,
                      height: 1.2,
                      fontFamily: 'OpenSans Regular',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xffa311f2)),
                      strokeWidth: 3.0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

