import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  String _selectedLanguage = 'English';
  bool _locationServices = true;
  bool _analytics = true;
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
                  'Receive push notifications for bookings and updates',
                  _pushNotifications,
                  (value) => setState(() => _pushNotifications = value),
                  Icons.notifications_outlined,
                ),
                _buildSwitchTile(
                  context,
                  'Email Notifications',
                  'Receive email updates about your bookings',
                  _emailNotifications,
                  (value) => setState(() => _emailNotifications = value),
                  Icons.email_outlined,
                ),
                _buildSwitchTile(
                  context,
                  'SMS Notifications',
                  'Receive SMS updates for important bookings',
                  _smsNotifications,
                  (value) => setState(() => _smsNotifications = value),
                  Icons.sms_outlined,
                ),
              ],
            ),
            _buildSection(
              context,
              'Language & Region',
              [
                _buildListTile(
                  context,
                  'Language',
                  _selectedLanguage,
                  Icons.language,
                  () => _showLanguageDialog(context),
                ),
              ],
            ),
            _buildSection(
              context,
              'Privacy',
              [
                _buildSwitchTile(
                  context,
                  'Location Services',
                  'Allow app to access your location',
                  _locationServices,
                  (value) => setState(() => _locationServices = value),
                  Icons.location_on_outlined,
                ),
                _buildSwitchTile(
                  context,
                  'Analytics',
                  'Help improve the app by sharing usage data',
                  _analytics,
                  (value) => setState(() => _analytics = value),
                  Icons.analytics_outlined,
                ),
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
        if (title != 'Analytics')
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

  void _showLanguageDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languages = ['English', 'Nepali', 'Hindi'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Select Language',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(
                language,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
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
