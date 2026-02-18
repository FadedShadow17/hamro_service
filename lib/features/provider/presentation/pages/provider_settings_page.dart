import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/view_model/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/widgets/logout_confirmation_dialog.dart';
import 'provider_about_page.dart';

class ProviderSettingsPage extends ConsumerStatefulWidget {
  const ProviderSettingsPage({super.key});

  @override
  ConsumerState<ProviderSettingsPage> createState() => _ProviderSettingsPageState();
}

class _ProviderSettingsPageState extends ConsumerState<ProviderSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _autoAcceptBookings = false;
  bool _showAvailability = true;
  String _paymentMethod = 'Bank Transfer';
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection(
              context,
              'Notifications',
              [
                _buildSwitchTile(
                  context,
                  'Push Notifications',
                  'Receive push notifications for new bookings',
                  _pushNotifications,
                  (value) => setState(() => _pushNotifications = value),
                  Icons.notifications_outlined,
                ),
                _buildSwitchTile(
                  context,
                  'Email Notifications',
                  'Receive email updates about bookings',
                  _emailNotifications,
                  (value) => setState(() => _emailNotifications = value),
                  Icons.email_outlined,
                ),
                _buildSwitchTile(
                  context,
                  'SMS Notifications',
                  'Receive SMS for urgent bookings',
                  _smsNotifications,
                  (value) => setState(() => _smsNotifications = value),
                  Icons.sms_outlined,
                ),
              ],
            ),
            _buildSection(
              context,
              'Service Availability',
              [
                _buildSwitchTile(
                  context,
                  'Auto Accept Bookings',
                  'Automatically accept new booking requests',
                  _autoAcceptBookings,
                  (value) => setState(() => _autoAcceptBookings = value),
                  Icons.check_circle_outline,
                ),
                _buildSwitchTile(
                  context,
                  'Show Availability',
                  'Display your availability to customers',
                  _showAvailability,
                  (value) => setState(() => _showAvailability = value),
                  Icons.visibility_outlined,
                ),
                _buildListTile(
                  context,
                  'Manage Availability',
                  'Set your working hours and days',
                  Icons.schedule,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manage availability feature coming soon')),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Payment Settings',
              [
                _buildListTile(
                  context,
                  'Payment Method',
                  _paymentMethod,
                  Icons.payment,
                  () => _showPaymentMethodDialog(context),
                ),
                _buildListTile(
                  context,
                  'Payment History',
                  'View your earnings and transactions',
                  Icons.history,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment history feature coming soon')),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Appearance',
              [
                _buildThemeToggle(context),
              ],
            ),
            _buildSection(
              context,
              'Security',
              [
                _buildSwitchTile(
                  context,
                  'Biometric Authentication',
                  'Use fingerprint or face ID to login',
                  _biometricAuth,
                  (value) => setState(() => _biometricAuth = value),
                  Icons.fingerprint,
                ),
                _buildSwitchTile(
                  context,
                  'Two-Factor Authentication',
                  'Add an extra layer of security',
                  _twoFactorAuth,
                  (value) => setState(() => _twoFactorAuth = value),
                  Icons.security,
                ),
                _buildListTile(
                  context,
                  'Change Password',
                  'Update your account password',
                  Icons.lock_outline,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change password feature coming soon')),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Support',
              [
                _buildListTile(
                  context,
                  'About',
                  'Learn more about the app',
                  Icons.info,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProviderAboutPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Account',
              [
                _buildLogoutTile(context),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primaryBlue,
          ),
        ),
        if (title != 'Show Availability' && title != 'Two-Factor Authentication')
          Divider(
            height: 1,
            indent: 60,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          onTap: onTap,
        ),
        Divider(
          height: 1,
          indent: 60,
          color: isDark ? Colors.grey[800] : Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              themeMode == AppThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          title: Text(
            'Dark Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            'Switch between light and dark theme',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          trailing: Switch(
            value: themeMode == AppThemeMode.dark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.logout,
              color: Colors.red,
              size: 22,
            ),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          subtitle: Text(
            'Sign out of your account',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          onTap: () async {
            final confirmed = await LogoutConfirmationDialog.show(context);
            if (confirmed == true && mounted) {
              final navigator = Navigator.of(context);
              await ref.read(authViewModelProvider.notifier).logout();
              if (mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            }
          },
        ),
      ],
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paymentMethods = ['Bank Transfer', 'eSewa', 'FonePay', 'Cash'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Select Payment Method',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: paymentMethods.map((method) {
            return RadioListTile<String>(
              title: Text(
                method,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              value: method,
              groupValue: _paymentMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                  Navigator.of(context).pop();
                }
              },
              activeColor: AppColors.primaryBlue,
            );
          }).toList(),
        ),
      ),
    );
  }
}
