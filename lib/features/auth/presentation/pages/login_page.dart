import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hamro_service/features/auth/presentation/pages/signup_page.dart';
import 'package:hamro_service/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hamro_service/features/auth/presentation/state/auth_state.dart';
import 'package:hamro_service/features/forgot_password/presentation/pages/forgot_password_page.dart';
import 'package:hamro_service/features/role/presentation/pages/role_page.dart';
import 'package:hamro_service/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hamro_service/features/provider/presentation/pages/provider_dashboard_page.dart';
import 'package:hamro_service/core/services/storage/user_session_service.dart';
import 'package:hamro_service/core/widgets/animated_text_field.dart';
import 'package:hamro_service/core/services/sensors/biometric_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _hasNavigated = false;
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricAvailable = false;
  bool _isCheckingBiometric = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isSupported = await _biometricService.isDeviceSupported();
      if (!isSupported) {
        if (mounted) {
          setState(() {
            _isBiometricAvailable = false;
            _isCheckingBiometric = false;
          });
        }
        return;
      }
      
      final hasEnrolled = await _biometricService.hasEnrolledBiometrics();
      final availableBiometrics = await _biometricService.getAvailableBiometrics();
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = hasEnrolled && availableBiometrics.isNotEmpty;
          _isCheckingBiometric = false;
        });
      }
    } catch (e) {
      print('[LoginPage] Error checking biometric availability: $e');
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _isCheckingBiometric = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authenticated = await _biometricService.authenticate();
    if (authenticated && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final lastEmail = prefs.getString('last_login_email');
      final lastPassword = prefs.getString('last_login_password');
      
      if (lastEmail != null && lastPassword != null) {
        ref.read(authViewModelProvider.notifier).login(
          emailOrUsername: lastEmail,
          password: lastPassword,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login with email and password first to enable biometric login'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_login_email', email);
    await prefs.setString('last_login_password', password);

    ref
        .read(authViewModelProvider.notifier)
        .login(emailOrUsername: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null && !_hasNavigated) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted && Navigator.of(context).canPop() == false) {
            final prefs = await SharedPreferences.getInstance();
            final sessionService = UserSessionService(prefs: prefs);
            final role = next.user?.role ?? sessionService.getRole();
            final roleSelected = prefs.getBool('role_selected') ?? false;
            
            if (!roleSelected) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const RolePage()),
              );
            } else {
              if (role == 'provider') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ProviderDashboardPage()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const DashboardPage()),
                );
              }
            }
          }
        });
      }

      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.errorMessage!)),
            );
          }
        });
      }
    });
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Welcome Back',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 16,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 400),
                            padding: const EdgeInsets.all(32),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AnimatedTextField(
                                  controller: _emailController,
                                  label: 'E-mail',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                AnimatedTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ForgotPasswordPage(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _AppButton(
                                  text: 'LOGIN',
                                  onPressed: _handleLogin,
                                  isLoading: authState.isLoading,
                                ),
                                if (!_isCheckingBiometric && _isBiometricAvailable) ...[
                                  const SizedBox(height: 24),
                                  Center(
                                    child: IconButton(
                                      icon: const Icon(Icons.fingerprint, size: 48),
                                      color: Theme.of(context).colorScheme.primary,
                                      onPressed: _handleBiometricLogin,
                                      tooltip: 'Login with fingerprint',
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _PremiumSocialButton(
                                      icon: Icons.facebook,
                                      label: 'Facebook',
                                      iconColor: Colors.white,
                                      backgroundColor: const Color(0xFF1877F2),
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 16),
                                    _PremiumSocialButton(
                                      icon: Icons.g_mobiledata,
                                      label: 'Google',
                                      iconColor: const Color(0xFF4285F4),
                                      backgroundColor: Colors.white,
                                      borderColor: Colors.grey[300]!,
                                      textColor: Colors.black87,
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Don\'t have an account? ',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SignupPage(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class _AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _AppButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}

class _PremiumSocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _PremiumSocialButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    this.borderColor,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTextColor = textColor ?? 
        (isDark ? Colors.white : Colors.black87);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor!,
                      width: 1.5,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
