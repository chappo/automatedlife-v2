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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NWSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: NWSpacing.xLarge),
                
                // App logo and title
                _buildHeader(theme),
                
                const SizedBox(height: NWSpacing.xLarge),
                
                // Login form card
                _buildLoginFormCard(theme),
                
                const SizedBox(height: NWSpacing.large),
                
                // Additional options
                _buildAdditionalOptions(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // App logo with enhanced design
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF77B42D), // AL brand green
                Color(0xFF558B2F), // Darker AL green
              ],
            ),
            borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(-3, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apartment_outlined,
                size: 36,
                color: Colors.white,
                semanticLabel: 'Automated Life Building Manager logo',
              ),
              const SizedBox(height: 4),
              Text(
                'AL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginFormCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(NWDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(NWSpacing.xLarge),
        child: _buildLoginForm(theme),
      ),
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
          NWTextField.password(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            validator: (value) => NWValidators.required(value, fieldName: 'Password'),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}