import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Icon Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, Color(0xFF6D5DF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.privacy_tip_rounded, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Your Privacy Matters',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Last Updated: May 25, 2026',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Policy Sections
            _buildSection(
              title: '1. Information We Collect',
              content: 'We collect information you provide directly to us when creating an account, syncing transactions, or communicating with us. This includes your name, email address, profile photo, and any financial transactions you record in the application.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '2. How We Use Your Information',
              content: 'Your financial data is used solely to provide budget tracking features, analytics, and bill-splitting capabilities. If you split a bill with another user, your display name and specific transaction amount will be shared with that user. We do not sell or monetize your financial data.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '3. Data Sync & Cloud Storage',
              content: 'To facilitate bill splitting and cross-device sync, transaction information and user details are securely stored in Firebase Cloud Firestore. Local offline storage utilizes an encrypted SQLite database on your device.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '4. Security Measures',
              content: 'We implement industry-standard encryption protocols (SSL/TLS) for data in transit and in storage. Firebase Authentication secures your login credentials, and database rules enforce that only authorized users can read or write transaction records.',
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: '5. Your Rights & Choice',
              content: 'You can update your account information, delete your transaction history, or completely close your account at any time through the Profile and Settings screens. Contact us at support@budgettracker.com if you require assistance.',
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
