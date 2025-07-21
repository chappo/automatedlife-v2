import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../accessibility/touch_targets.dart';
import '../../tokens/dimensions.dart';
import '../../tokens/spacing.dart';

/// Accessible text field component with validation support
/// 
/// Provides consistent styling, validation, and accessibility features
/// across the application. Automatically handles touch targets, focus,
/// and semantic labeling.
class NWTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? semanticLabel;
  final AutovalidateMode autovalidateMode;
  final String? Function(String?)? validator;
  final bool isRequired;
  
  const NWTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.value,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.controller,
    this.focusNode,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.semanticLabel,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
    this.isRequired = false,
  });
  
  /// Creates an email text field with appropriate keyboard and validation
  const NWTextField.email({
    super.key,
    this.label = 'Email',
    this.hint = 'Enter your email address',
    this.helperText,
    this.errorText,
    this.value,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.controller,
    this.focusNode,
    this.semanticLabel,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
    this.isRequired = true,
  }) : keyboardType = TextInputType.emailAddress,
       textInputAction = TextInputAction.next,
       obscureText = false,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       prefixIcon = const Icon(Icons.email_outlined),
       suffixIcon = null;
  
  /// Creates a password text field with visibility toggle
  const NWTextField.password({
    super.key,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.helperText,
    this.errorText,
    this.value,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.controller,
    this.focusNode,
    this.semanticLabel,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
    this.isRequired = true,
  }) : keyboardType = TextInputType.visiblePassword,
       textInputAction = TextInputAction.done,
       obscureText = true,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       prefixIcon = const Icon(Icons.lock_outlined),
       suffixIcon = null;

  @override
  State<NWTextField> createState() => _NWTextFieldState();
}

class _NWTextFieldState extends State<NWTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Build suffix icon with password visibility toggle if needed
    Widget? suffixIcon = widget.suffixIcon;
    if (widget.obscureText && suffixIcon == null) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          semanticLabel: _obscureText ? 'Show password' : 'Hide password',
        ),
        onPressed: _togglePasswordVisibility,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }

    // Build the label with required indicator
    String? effectiveLabel = widget.label;
    if (widget.isRequired && effectiveLabel != null) {
      effectiveLabel = '$effectiveLabel *';
    }

    final textField = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: effectiveLabel,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NWDimensions.radiusMedium),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: _hasFocus 
          ? colorScheme.surface
          : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NWSpacing.medium,
          vertical: NWSpacing.medium,
        ),
      ),
    );

    // Wrap with accessibility features
    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hint,
      textField: true,
      enabled: widget.enabled,
      focusable: true,
      child: AccessibleTouchTargets.ensureMinimumTouchTarget(
        child: textField,
      ),
    );
  }
}