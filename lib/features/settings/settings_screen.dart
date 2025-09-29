import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _currency = 'USD';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileSection(),
            const SizedBox(height: 24),
            _PreferencesSection(),
            const SizedBox(height: 24),
            _SecuritySection(),
            const SizedBox(height: 24),
            _AppSection(),
            const SizedBox(height: 24),
            _AboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _ProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'john.doe@example.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Navigate to edit profile
                },
                icon: Icon(
                  Icons.edit,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _PreferencesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Get notified about budget alerts',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
          ),
          _SettingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
          ),
          _SettingsTile(
            icon: Icons.attach_money,
            title: 'Currency',
            subtitle: _currency,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showCurrencyDialog(),
          ),
          _SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _language,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(),
          ),
        ],
      ),
    );
  }

  Widget _SecuritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face ID',
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
          ),
          _SettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to change password
            },
          ),
          _SettingsTile(
            icon: Icons.security,
            title: 'Privacy Settings',
            subtitle: 'Manage your privacy',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
        ],
      ),
    );
  }

  Widget _AppSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.backup,
            title: 'Backup & Sync',
            subtitle: 'Sync data across devices',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to backup settings
            },
          ),
          _SettingsTile(
            icon: Icons.storage,
            title: 'Storage',
            subtitle: 'Manage app storage',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to storage settings
            },
          ),
          _SettingsTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to help
            },
          ),
        ],
      ),
    );
  }

  Widget _AboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: '1.0.0',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show version info
            },
          ),
          _SettingsTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to terms
            },
          ),
          _SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _SettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textGrey,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CurrencyOption('USD', 'US Dollar'),
            _CurrencyOption('EUR', 'Euro'),
            _CurrencyOption('GBP', 'British Pound'),
            _CurrencyOption('JPY', 'Japanese Yen'),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption('English'),
            _LanguageOption('Spanish'),
            _LanguageOption('French'),
            _LanguageOption('German'),
          ],
        ),
      ),
    );
  }

  Widget _CurrencyOption(String code, String name) {
    return ListTile(
      title: Text(code),
      subtitle: Text(name),
      onTap: () {
        setState(() {
          _currency = code;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _LanguageOption(String language) {
    return ListTile(
      title: Text(language),
      onTap: () {
        setState(() {
          _language = language;
        });
        Navigator.pop(context);
      },
    );
  }
}
