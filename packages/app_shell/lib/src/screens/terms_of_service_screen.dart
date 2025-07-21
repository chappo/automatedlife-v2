import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Screen displaying the terms of service
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NWSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.all(NWSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: NWSpacing.small),
                      Text(
                        'Terms & Conditions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NWSpacing.small),
                  Text(
                    'Last updated: November 2024',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: NWSpacing.large),

            // Terms of Service Content
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(NWSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    theme,
                    'Agreement to Terms',
                    'By downloading, accessing, or using the Building Manager mobile application (\"App\"), you agree to be bound by these Terms of Service (\"Terms\"). If you do not agree to these Terms, do not use the App.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Description of Service',
                    'Building Manager is a mobile application that provides building management services including but not limited to:\n\n• Building access management\n• Maintenance request tracking\n• Communication with building management\n• Document sharing and notifications\n• Calendar and booking services',
                  ),
                  
                  _buildSection(
                    theme,
                    'User Accounts',
                    'To use certain features of the App, you must create an account. You are responsible for:\n\n• Maintaining the confidentiality of your account credentials\n• All activities that occur under your account\n• Immediately notifying us of any unauthorized use\n• Ensuring your account information is accurate and up-to-date',
                  ),
                  
                  _buildSection(
                    theme,
                    'Acceptable Use',
                    'You agree to use the App only for lawful purposes and in accordance with these Terms. You agree NOT to:\n\n• Use the App for any unlawful or fraudulent purpose\n• Attempt to gain unauthorized access to the App or its systems\n• Interfere with or disrupt the App\'s functionality\n• Transmit any harmful or malicious code\n• Violate any applicable laws or regulations',
                  ),
                  
                  _buildSection(
                    theme,
                    'Privacy and Data Protection',
                    'Your privacy is important to us. Our collection and use of personal information is governed by our Privacy Policy, which is incorporated into these Terms by reference.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Intellectual Property',
                    'The App and its original content, features, and functionality are owned by Automated Life and are protected by international copyright, trademark, and other intellectual property laws.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Limitation of Liability',
                    'To the maximum extent permitted by law, Automated Life shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, or use.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Disclaimers',
                    'The App is provided on an \"AS IS\" and \"AS AVAILABLE\" basis. We make no warranties, expressed or implied, and hereby disclaim all other warranties including, without limitation, implied warranties of merchantability, fitness for a particular purpose, or non-infringement.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Termination',
                    'We may terminate or suspend your account and access to the App immediately, without prior notice, for any reason, including if you breach these Terms.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Governing Law',
                    'These Terms are governed by and construed in accordance with the laws of Australia, without regard to conflict of law principles.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Changes to Terms',
                    'We reserve the right to modify these Terms at any time. We will provide notice of material changes by posting the updated Terms in the App and updating the \"Last updated\" date.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Contact Information',
                    'If you have any questions about these Terms, please contact us:\n\nEmail: legal@automatedlife.com.au\nPhone: +61 1300 888 712\nAddress: Automated Life Pty Ltd\nLevel 1, 123 Building Street\nSydney, NSW 2000\nAustralia',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    String content, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: NWSpacing.small),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        if (!isLast) const SizedBox(height: NWSpacing.large),
      ],
    );
  }
}