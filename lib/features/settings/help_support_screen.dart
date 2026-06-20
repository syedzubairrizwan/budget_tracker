import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General Inquiry';
  bool _isSubmitting = false;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I split a bill with another user?',
      'answer': 'When adding a transaction, toggle the "Split Bill" option at the bottom. Tap the participant row to search for a registered user by email or name. Set their share, and the bill is recorded in both of your books once saved.'
    },
    {
      'question': 'How do I settle up a split balance?',
      'answer': 'Go to the "Settle Up" tab from the bottom navigation. Tap "Settle Up" on any active split card. A notification will be sent to the expense creator asking them to approve or deny the settlement.'
    },
    {
      'question': 'Can I export my transactions data?',
      'answer': 'Yes! Navigate to Settings and tap "Export Transactions (CSV)". You can select a date range (30 days, custom, or all time) and download the generated CSV file directly to your device storage.'
    },
    {
      'question': 'Does this app work offline?',
      'answer': 'Yes. Budget Tracker stores your transaction history locally in an SQLite database. Cloud sync with Firestore and bill-splitting features require an active internet connection.'
    },
    {
      'question': 'How do I change the currency symbol?',
      'answer': 'In Settings, go to Preferences and tap "Currency". You can choose between USD, EUR, GBP, JPY, and PKR.'
    }
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    // Simulate submission
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(
                'Ticket Submitted',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Thank you for reaching out! A support ticket has been created. Our team will contact you shortly.',
            style: GoogleFonts.inter(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Done',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      );
    });
  }

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
          'Help & Support',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQs Title
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.outfit(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // FAQs List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, width: 1),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        faq['question']!,
                        style: GoogleFonts.outfit(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      iconColor: AppColors.primaryColor,
                      collapsedIconColor: textSecondary,
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedAlignment: Alignment.topLeft,
                      children: [
                        Text(
                          faq['answer']!,
                          style: GoogleFonts.inter(
                            color: textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Contact Form Title
            Text(
              'Contact Support',
              style: GoogleFonts.outfit(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Can't find your answer? Send us a ticket directly.",
              style: GoogleFonts.inter(
                color: textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Support Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border, width: 1),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.inter(color: textPrimary, fontSize: 14),
                      decoration: _buildInputDecoration('Name', Icons.person_outline_rounded, isDark, border, textSecondary),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 14),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(color: textPrimary, fontSize: 14),
                      decoration: _buildInputDecoration('Email Address', Icons.email_outlined, isDark, border, textSecondary),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter your email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: cardBg,
                      style: GoogleFonts.inter(color: textPrimary, fontSize: 14),
                      decoration: _buildInputDecoration('Topic', Icons.help_outline_rounded, isDark, border, textSecondary),
                      items: ['General Inquiry', 'Bug Report', 'Account Issue', 'Feature Request']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                    ),
                    const SizedBox(height: 14),

                    // Message Field
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      style: GoogleFonts.inter(color: textPrimary, fontSize: 14),
                      decoration: _buildInputDecoration('How can we help you?', Icons.chat_bubble_outline_rounded, isDark, border, textSecondary).copyWith(
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please write your query message' : null,
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Send Message',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDark, Color border, Color textSecondary) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primaryColor.withOpacity(0.8), size: 18),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A).withOpacity(0.3) : Colors.grey.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border.withOpacity(0.6), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
      ),
    );
  }
}
