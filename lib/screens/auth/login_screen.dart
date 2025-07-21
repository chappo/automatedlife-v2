import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';

/// Login screen with email/password form
/// 
/// Provides accessible form with validation, error handling,
/// and remember me functionality. Integrates with the AuthService
/// for authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _subdomainController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _subdomainFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _showSubdomainField = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _subdomainController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _subdomainFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    // Load remembered email if available
    final storage = SecureStorageService();
    final savedEmail = await storage.getSavedEmail();
    if (savedEmail != null) {
      _emailController.text = savedEmail;
      _rememberMe = true;
      setState(() {});
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService.instance;
      final result = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        buildingSubdomain: _subdomainController.text.trim().isNotEmpty 
          ? _subdomainController.text.trim() 
          : null,
      );

      if (result.success && result.user != null) {
        // Save email if remember me is checked
        if (_rememberMe) {
          final storage = SecureStorageService();
          await storage.saveEmail(_emailController.text.trim());
        }

        // Navigation will be handled by AuthWrapper listening to auth state
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleSubdomainField() {
    setState(() {
      _showSubdomainField = !_showSubdomainField;
      if (!_showSubdomainField) {
        _subdomainController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NWSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: NWSpacing.extraLarge),
              
              // App logo and title
              _buildHeader(theme),
              
              const SizedBox(height: NWSpacing.extraLarge),
              
              // Login form
              _buildLoginForm(theme),
              
              const SizedBox(height: NWSpacing.large),
              
              // Additional options
              _buildAdditionalOptions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // App logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_outlined,
                size: 28,
                color: theme.colorScheme.onPrimary,
                semanticLabel: 'Automated Life Building Manager logo',
              ),
              const SizedBox(height: 2),
              Text(
                'AL',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: NWSpacing.medium),
        
        // Title
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: NWSpacing.small),
        
        // Subtitle
        Text(
          'Sign in to Automated Life Building Manager',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(NWSpacing.medium),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(NWDimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: NWSpacing.small),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NWSpacing.medium),
          ],

          // Building subdomain field (optional)
          if (_showSubdomainField) ...[
            NWTextField(
              controller: _subdomainController,
              focusNode: _subdomainFocusNode,
              label: 'Building Subdomain (Optional)',
              hint: 'e.g. mybuilding',
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: NWValidators.buildingSubdomain,
              prefixIcon: const Icon(Icons.business_outlined),
              onSubmitted: (_) => _emailFocusNode.requestFocus(),
            ),
            const SizedBox(height: NWSpacing.medium),
          ],
          
          // Email field
          NWTextField.email(
            controller: _emailController,
            focusNode: _emailFocusNode,
            validator: NWValidators.email,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          
          const SizedBox(height: NWSpacing.medium),
          
          // Password field
          NWTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            hint: 'Enter your password',
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            obscureText: _obscurePassword,
            validator: (value) => NWValidators.required(value, fieldName: 'Password'),
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: _togglePasswordVisibility,
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            ),
            onSubmitted: (_) => _handleLogin(),
          ),
          
          const SizedBox(height: NWSpacing.medium),
          
          // Remember me checkbox
          NWCheckbox(
            label: 'Remember my email',
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
            alignment: CrossAxisAlignment.start,
          ),
          
          const SizedBox(height: NWSpacing.large),
          
          // Login button
          NWPrimaryButton(
            text: 'Sign In',
            onPressed: _isLoading ? null : _handleLogin,
            isLoading: _isLoading,
            isFullWidth: true,
            semanticLabel: 'Sign in to your account',
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions(ThemeData theme) {
    return Column(
      children: [
        // Building subdomain toggle
        TextButton.icon(
          onPressed: _toggleSubdomainField,
          icon: Icon(_showSubdomainField ? Icons.remove : Icons.add),
          label: Text(_showSubdomainField 
            ? 'Hide Building Subdomain' 
            : 'Add Building Subdomain'),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: NWSpacing.medium),
        
        // Help text
        Text(
          'Need help? Contact your building administrator',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}