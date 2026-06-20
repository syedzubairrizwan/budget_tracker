import 'package:budget_tracker/core/theme_bloc.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';
import 'package:budget_tracker/features/planned_payments/planned_payment_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/export_service.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/features/settings/privacy_policy_screen.dart';
import 'package:budget_tracker/features/settings/terms_conditions_screen.dart';
import 'package:budget_tracker/features/settings/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _currency = 'PKR';
  String _language = 'English';
  int _cycleStartDay = 1;
  int _alertThreshold = 80;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _currency = prefs.getString('currency_code') ?? 'PKR';
      _language = prefs.getString('language') ?? 'English';
      _cycleStartDay = prefs.getInt('budget_cycle_start') ?? 1;
      _alertThreshold = prefs.getInt('budget_alert_threshold') ?? 80;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = Provider.of<ThemeBloc>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences section
            _buildSectionCard(
              title: 'Preferences',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              children: [
                _settingsTile(
                  icon: Icons.notifications_active_outlined,
                  color: Colors.blueAccent,
                  title: 'Notifications',
                  subtitle: 'Budget alerts and reports',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      _saveSetting('notifications_enabled', value);
                    },
                    activeColor: AppColors.primaryColor,
                  ),
                ),
                _settingsTile(
                  icon: Icons.dark_mode_outlined,
                  color: Colors.purpleAccent,
                  title: 'Dark Mode',
                  subtitle: 'Switch to a dark color theme',
                  trailing: Switch(
                    value: themeBloc.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeBloc.toggleTheme(value);
                    },
                    activeColor: AppColors.primaryColor,
                  ),
                ),
                _settingsTile(
                  icon: Icons.monetization_on_outlined,
                  color: const Color(0xFF10B981),
                  title: 'Currency',
                  subtitle: _currency,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => _showCurrencyDialog(),
                ),
                _settingsTile(
                  icon: Icons.translate_rounded,
                  color: Colors.amber,
                  title: 'Language',
                  subtitle: _language,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => _showLanguageDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Budget cycle settings
            _buildSectionCard(
              title: 'Budget Settings',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              children: [
                _settingsTile(
                  icon: Icons.calendar_month_outlined,
                  color: Colors.indigoAccent,
                  title: 'Cycle Start Day',
                  subtitle: 'Day $_cycleStartDay of the month',
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => _showCycleStartDialog(),
                ),
                _settingsTile(
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orangeAccent,
                  title: 'Alert Warning Threshold',
                  subtitle: 'Warn when budget reaches $_alertThreshold%',
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => _showThresholdDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // App section
            _buildSectionCard(
              title: 'App Utilities',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              children: [
                _settingsTile(
                  icon: Icons.file_download_outlined,
                  color: Colors.teal,
                  title: 'Export Transactions (CSV)',
                  subtitle: 'Download transaction history',
                  trailing: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                        )
                      : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: _isExporting ? null : () => _exportData(context),
                ),
                _settingsTile(
                  icon: Icons.delete_forever_outlined,
                  color: Colors.redAccent,
                  title: 'Reset App Data',
                  subtitle: 'Clear all databases & cache',
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => _showResetDataDialog(context),
                ),
                _settingsTile(
                  icon: Icons.help_outline_rounded,
                  color: Colors.cyan,
                  title: 'Help & Support',
                  subtitle: 'FAQ and support desk',
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // About section
            _buildSectionCard(
              title: 'Legal & Info',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              children: [
                _settingsTile(
                  icon: Icons.info_outline_rounded,
                  color: Colors.grey,
                  title: 'App Version',
                  subtitle: '1.0.0 (Production Build)',
                  trailing: const Text(
                    'Up to date',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                _settingsTile(
                  icon: Icons.description_outlined,
                  color: Colors.blueGrey,
                  title: 'Terms of Service',
                  subtitle: 'Legal usage agreements',
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen()));
                  },
                ),
                _settingsTile(
                  icon: Icons.privacy_tip_outlined,
                  color: Colors.teal,
                  title: 'Privacy Policy',
                  subtitle: 'How we manage data',
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
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

  Widget _buildSectionCard({
    required String title,
    required Color cardBg,
    required Color border,
    required Color textPrimary,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final transactionState = context.read<TransactionBloc>().state;
    if (transactionState is! TransactionLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    final period = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Export Period', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Time'),
              onTap: () => Navigator.pop(context, 'all'),
            ),
            ListTile(
              title: const Text('Last 30 Days'),
              onTap: () => Navigator.pop(context, '30days'),
            ),
            ListTile(
              title: const Text('Custom Range'),
              onTap: () => Navigator.pop(context, 'custom'),
            ),
          ],
        ),
      ),
    );

    if (period == null) return;
    if (!context.mounted) return;

    DateTime? startDate;
    DateTime? endDate;

    if (period == '30days') {
      endDate = DateTime.now();
      startDate = endDate.subtract(const Duration(days: 30));
    } else if (period == 'custom') {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 1)),
      );
      if (range == null) return;
      if (!context.mounted) return;
      startDate = range.start;
      endDate = range.end;
    }

    List<Transaction> filteredTransactions = transactionState.transactions;
    if (startDate != null && endDate != null) {
      filteredTransactions = transactionState.transactions.where((t) {
        return t.date.isAfter(startDate!.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    if (filteredTransactions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No transactions found for the selected period')),
        );
      }
      return;
    }

    setState(() => _isExporting = true);
    final exportService = ExportService();
    try {
      final file = await exportService.exportToCSV(filteredTransactions);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${filteredTransactions.length} items to ${file.path.split('/').last} successfully!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select Currency', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _currencyOption('USD', 'US Dollar (\$)'),
            _currencyOption('EUR', 'Euro (€)'),
            _currencyOption('GBP', 'British Pound (£)'),
            _currencyOption('JPY', 'Japanese Yen (¥)'),
            _currencyOption('PKR', 'Pakistani Rupee (Rs)'),
          ],
        ),
      ),
    );
  }

  Widget _currencyOption(String code, String name) {
    return ListTile(
      title: Text(code, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      subtitle: Text(name, style: GoogleFonts.inter(fontSize: 12)),
      trailing: _currency == code ? const Icon(Icons.check_rounded, color: AppColors.primaryColor) : null,
      onTap: () {
        setState(() => _currency = code);
        _saveSetting('currency_code', code);
        Navigator.pop(context);
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select Language', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption('English'),
            _languageOption('Spanish'),
            _languageOption('French'),
            _languageOption('German'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String lang) {
    return ListTile(
      title: Text(lang, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      trailing: _language == lang ? const Icon(Icons.check_rounded, color: AppColors.primaryColor) : null,
      onTap: () {
        setState(() => _language = lang);
        _saveSetting('language', lang);
        Navigator.pop(context);
      },
    );
  }

  void _showCycleStartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select Start Day', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 28,
            itemBuilder: (context, index) {
              final day = index + 1;
              return ListTile(
                title: Text('Day $day of Month', style: GoogleFonts.inter(fontSize: 14)),
                trailing: _cycleStartDay == day ? const Icon(Icons.check_rounded, color: AppColors.primaryColor) : null,
                onTap: () {
                  setState(() => _cycleStartDay = day);
                  _saveSetting('budget_cycle_start', day);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showThresholdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select Warning Threshold', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [50, 75, 80, 90, 100].map((val) {
            return ListTile(
              title: Text('$val% of Budget', style: GoogleFonts.inter(fontSize: 14)),
              trailing: _alertThreshold == val ? const Icon(Icons.check_rounded, color: AppColors.primaryColor) : null,
              onTap: () {
                setState(() => _alertThreshold = val);
                _saveSetting('budget_alert_threshold', val);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text('Reset All Data?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will permanently delete all your transactions, budgets, goals, and customized category data. This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await DatabaseService.instance.clearAllData();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (context.mounted) {
                  // Reload BLoCs to clear UI
                  context.read<TransactionBloc>().add(LoadTransactions());
                  context.read<CategoryBloc>().add(LoadCategories());
                  context.read<BudgetBloc>().add(LoadBudgets());
                  context.read<GoalBloc>().add(LoadGoals());
                  context.read<PlannedPaymentBloc>().add(LoadPlannedPayments());
                  
                  // Reload settings in the current screen
                  _loadSettings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('App successfully reset to default state.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.errorColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reset failed: $e')),
                  );
                }
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
