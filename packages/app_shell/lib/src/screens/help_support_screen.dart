import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen for help and support resources
class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NWSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(theme),
            
            const SizedBox(height: NWSpacing.large),
            
            // Quick Help Section
            _buildQuickHelpSection(theme),
            
            const SizedBox(height: NWSpacing.large),
            
            // Contact Support Section
            _buildContactSupportSection(theme),
            
            const SizedBox(height: NWSpacing.large),
            
            // Resources Section
            _buildResourcesSection(theme),
            
            const SizedBox(height: NWSpacing.large),
            
            // App Information
            _buildAppInfoSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF77B42D), // AL brand green
            const Color(0xFF558B2F), // Darker AL green
          ],
        ),
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
      ),
      padding: const EdgeInsets.all(NWSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: NWSpacing.medium),
              Expanded(
                child: Text(
                  'We\'re Here to Help',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NWSpacing.small),
          Text(
            'Get assistance with Building Manager features, account issues, or technical support.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Quick Help',
      children: [
        _buildHelpItem(
          theme: theme,
          icon: Icons.question_answer,
          title: 'Frequently Asked Questions',
          subtitle: 'Find answers to common questions',
          onTap: () => _showFAQs(theme),
        ),
        _buildHelpItem(
          theme: theme,
          icon: Icons.book_outlined,
          title: 'User Guide',
          subtitle: 'Learn how to use Building Manager features',
          onTap: () => _showUserGuide(theme),
        ),
        _buildHelpItem(
          theme: theme,
          icon: Icons.video_library_outlined,
          title: 'Video Tutorials',
          subtitle: 'Watch step-by-step video guides',
          onTap: () => _showVideoTutorials(theme),
        ),
      ],
    );
  }

  Widget _buildContactSupportSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Contact Support',
      children: [
        _buildHelpItem(
          theme: theme,
          icon: Icons.phone,
          title: 'Call Support',
          subtitle: '+61 1300 888 712',
          onTap: () => _makePhoneCall('+61 1300 888 712'),
        ),
        _buildHelpItem(
          theme: theme,
          icon: Icons.email_outlined,
          title: 'Email Support',
          subtitle: 'support@automatedlife.com.au',
          onTap: () => _sendEmail('support@automatedlife.com.au'),
        ),
        _buildHelpItem(
          theme: theme,
          icon: Icons.chat_outlined,
          title: 'Live Chat',
          subtitle: 'Chat with our support team',
          onTap: () => _openLiveChat(),
        ),
        _buildHelpItem(
          theme: theme,
          icon: Icons.bug_report_outlined,
          title: 'Report a Bug',
          subtitle: 'Help us improve the app',
          onTap: () => _reportBug(theme),
        ),
      ],
    );
  }

  Widget _buildResourcesSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Resources',
      children: [
        _buildHelpItem(
          theme: theme,
          icon: Icons.web,
          title: 'Automated Life Website',
          subtitle: 'Visit our main website',
          onTap: () => _openWebsite('https://automatedlife.com.au'),
        ),
        _buildHelpItem(
          theme: theme,
          icon: Icons.article_outlined,
          title: 'Release Notes',
          subtitle: 'See what\'s new in this version',
          onTap: () => _showReleaseNotes(theme),
        ),
        _buildHelpItem(
          theme: theme,
          icon: Icons.feedback_outlined,
          title: 'Send Feedback',
          subtitle: 'Share your thoughts and suggestions',
          onTap: () => _sendFeedback(),
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
      ),
      padding: const EdgeInsets.all(NWSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: NWSpacing.medium),
          _buildInfoRow(theme, 'Version', '1.0.0 (Beta)'),
          _buildInfoRow(theme, 'Build', '1'),
          _buildInfoRow(theme, 'Platform', 'Mobile'),
          _buildInfoRow(theme, 'Developer', 'Automated Life'),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(NWSpacing.large),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Building Manager Support Request',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openLiveChat() {
    // TODO: Implement live chat integration
    // This could open a web view, third-party chat SDK, or redirect to website chat
  }

  void _sendFeedback() {
    // TODO: Implement feedback form or email template
  }

  void _showFAQs(ThemeData theme) {
    // TODO: Navigate to FAQ screen or show dialog with common questions
  }

  void _showUserGuide(ThemeData theme) {
    // TODO: Navigate to user guide screen or open external documentation
  }

  void _showVideoTutorials(ThemeData theme) {
    // TODO: Navigate to video tutorials or open external video library
  }

  void _reportBug(ThemeData theme) {
    // TODO: Navigate to bug report form or open email with template
  }

  void _showReleaseNotes(ThemeData theme) {
    // TODO: Show release notes dialog or navigate to release notes screen
  }
}