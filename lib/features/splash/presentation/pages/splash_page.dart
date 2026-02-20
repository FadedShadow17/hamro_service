import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hamro_service/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hamro_service/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hamro_service/features/provider/presentation/pages/provider_dashboard_page.dart';
import 'package:hamro_service/features/icon_screen/presentation/pages/icon_page.dart';
import 'package:hamro_service/core/services/storage/user_session_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      await ref.read(authViewModelProvider.notifier).checkAuth();

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final authState = ref.read(authViewModelProvider);

      if (authState.isAuthenticated && authState.user != null) {
        if (mounted) {
          final sessionService = UserSessionService(prefs: await SharedPreferences.getInstance());
          // Get role from backend (JWT token or user data) - this is the source of truth
          final role = authState.user?.role ?? sessionService.getRole();
          
          // Save role to session service if not already saved
          if (role != null && role.isNotEmpty) {
            final currentSessionRole = sessionService.getRole();
            if (currentSessionRole != role) {
              await sessionService.saveRole(role);
            }
          }
          
          // Navigate directly based on role, default to user dashboard if no role
          if (role == 'provider') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProviderDashboardPage()),
            );
          } else {
            // Default to user dashboard if role is null, empty, or 'user'
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const IconPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const IconPage()),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFFF5F7FA),
                    const Color(0xFFE8ECF1),
                    const Color(0xFFDDE4EA),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      child: Text(
                        'Hamro Service App',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        'Book home services in Kathmandu',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 16,
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
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          strokeWidth: 3.0,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
