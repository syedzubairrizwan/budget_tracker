import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE9621B), Color(0xFFFCB045)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.description_rounded, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Terms of Service',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Effective Date: May 25, 2026',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '1. Acceptance of Terms',
              content: 'By accessing or using the Budget Tracker application, you agree to comply with and be bound by these Terms of Service. If you do not agree to these terms, you must not use or access the services.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '2. User Accounts',
              content: 'You must maintain accurate account information. You are responsible for safeguarding your login credentials. We are not responsible for any unauthorized access resulting from your failure to protect your password.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '3. Acceptable Use',
              content: 'You agree to use this application only for personal financial management and sharing expenses with other users. You must not use the application to engage in fraud, money laundering, or other illicit activities.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '4. Service Disclaimers',
              content: 'The application is provided "as is" without warranty of any kind. Budget Tracker does not guarantee the absolute accuracy of parsed transaction text or receipts, nor does it provide professional financial or tax advice.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '5. Modifications to Service',
              content: 'We reserve the right to modify, suspend, or discontinue any aspect of the service at any time. We will notify you of material changes to these Terms by posting them inside the app.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required Color cardBg,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
