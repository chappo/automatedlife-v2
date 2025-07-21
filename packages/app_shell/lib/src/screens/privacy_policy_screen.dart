import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Screen displaying the privacy policy
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                        Icons.privacy_tip_outlined,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: NWSpacing.small),
                      Text(
                        'Your Privacy Matters',
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

            // Privacy Policy Content
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
                    'Introduction',
                    'Automated Life (\"we\", \"our\", or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Building Manager mobile application.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Information We Collect',
                    'Personal Information: We may collect personal information such as your name, email address, phone number, and building access credentials.\n\nUsage Data: We collect information about how you use our app, including features accessed, time spent, and interaction patterns.\n\nDevice Information: We may collect information about your device, including device type, operating system, and unique device identifiers.',
                  ),
                  
                  _buildSection(
                    theme,
                    'How We Use Your Information',
                    'We use the information we collect to:\n\n• Provide and maintain our services\n• Process transactions and manage building access\n• Send notifications and updates\n• Improve our app and services\n• Ensure security and prevent fraud\n• Comply with legal obligations',
                  ),
                  
                  _buildSection(
                    theme,
                    'Information Sharing',
                    'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• With your explicit consent\n• To comply with legal requirements\n• To protect our rights and safety\n• With trusted service providers who assist in app operations',
                  ),
                  
                  _buildSection(
                    theme,
                    'Data Security',
                    'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes encryption, secure servers, and regular security assessments.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Your Rights',
                    'You have the right to:\n\n• Access your personal information\n• Correct inaccurate information\n• Request deletion of your data\n• Opt-out of certain communications\n• Withdraw consent where applicable\n\nTo exercise these rights, please contact us using the information provided below.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Data Retention',
                    'We retain your personal information only as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required by law.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Changes to This Policy',
                    'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new Privacy Policy in the app and updating the \"Last updated\" date.',
                  ),
                  
                  _buildSection(
                    theme,
                    'Contact Us',
                    'If you have any questions about this Privacy Policy, please contact us:\n\nEmail: privacy@automatedlife.com.au\nPhone: +61 1300 888 712\nAddress: Automated Life Pty Ltd\nLevel 1, 123 Building Street\nSydney, NSW 2000\nAustralia',
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