import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/focus_manager.dart';

class KeyboardTextInputWidget extends StatefulWidget {
  /// Label displayed above the input field
  final String label;

  /// Controller for the text field
  final TextEditingController controller;

  /// Focus node for keyboard navigation
  final FocusNode focusNode;

  /// Placeholder text
  final String? placeholder;

  /// Type of keyboard to display
  final TextInputType keyboardType;

  /// Maximum number of lines
  final int maxLines;

  /// Maximum character length
  final int? maxLength;

  /// Validator function
  final String? Function(String?)? validator;

  /// Callback when field is submitted (Enter key)
  final VoidCallback? onFieldSubmitted;

  /// Callback when field value changes
  final void Function(String)? onChanged;

  /// Whether to obscure text (password field)
  final bool obscureText;

  /// Whether field is read-only
  final bool readOnly;

  /// Suffix icon widget
  final Widget? suffixIcon;

  /// Tooltip showing keyboard hints
  final String? tooltip;

  const KeyboardTextInputWidget({
    Key? key,
    required this.label,
    required this.controller,
    required this.focusNode,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.obscureText = false,
    this.readOnly = false,
    this.suffixIcon,
    this.tooltip,
  }) : super(key: key);

  @override
  State<KeyboardTextInputWidget> createState() =>
      _KeyboardTextInputWidgetState();
}

class _KeyboardTextInputWidgetState extends State<KeyboardTextInputWidget> {
  late FocusNode _internalFocusNode;
  bool _isFocused = false;
  bool _showTooltip = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode;
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
      _showTooltip = _isFocused && widget.tooltip != null;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    // Handle Tab to move to next field
    if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.tab) &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _internalFocusNode.nextFocus();
    }
    // Handle Shift+Tab to move to previous field
    else if (HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.tab) &&
        HardwareKeyboard.instance.isShiftPressed) {
      _internalFocusNode.previousFocus();
    }
    // Handle Enter to submit form
    else if (HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.enter) &&
        widget.maxLines == 1) {
      widget.onFieldSubmitted?.call();
    }
  }

  String? _validateInput(String? value) {
    if (widget.validator != null) {
      final result = widget.validator!(value);
      if (result != null) {
        setState(() {
          _errorMessage = result;
        });
        return result;
      }
    }
    setState(() {
      _errorMessage = null;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: theme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.secondaryText,
            ),
          ),
        ),

        // Input field with focus ring and keyboard listener
        FocusRingDecorator.buildFocusRingContainer(
          isFocused: _isFocused,
          context: context,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Focus(
              onKeyEvent: (node, event) {
                if (HardwareKeyboard.instance
                        .isLogicalKeyPressed(LogicalKeyboardKey.tab) ||
                    HardwareKeyboard.instance
                        .isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
                  _handleKeyEvent(event);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextFormField(
                controller: widget.controller,
                focusNode: _internalFocusNode,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                minLines: widget.maxLines == 1 ? 1 : null,
                maxLength: widget.maxLength,
                obscureText: widget.obscureText,
                readOnly: widget.readOnly,
                validator: _validateInput,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  // Re-validate on change if there's an error
                  if (_errorMessage != null) {
                    _validateInput(value);
                  }
                },
                onFieldSubmitted: (_) {
                  widget.onFieldSubmitted?.call();
                },
                style: theme.bodyMedium.copyWith(
                  color: widget.readOnly
                      ? theme.secondaryText.withValues(alpha: 0.5)
                      : theme.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: theme.bodyMedium.copyWith(
                    color: theme.secondaryText.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: widget.readOnly
                      ? theme.primary.withValues(alpha: 0.05)
                      : Colors.white,
                  prefixIcon: null,
                  suffixIcon: widget.suffixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: widget.suffixIcon!,
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.alternate,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.alternate,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.error,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.error,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.alternate.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  errorText: _errorMessage,
                  errorStyle: theme.bodySmall.copyWith(
                    color: theme.error,
                    fontWeight: FontWeight.w500,
                  ),
                  counterText: widget.maxLength != null ? '' : null,
                ),
              ),
            ),
          ),
        ),

        // Character counter (if maxLength is set)
        if (widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tooltip hint on focus
                if (_showTooltip && widget.tooltip != null)
                  Expanded(
                    child: Tooltip(
                      message: widget.tooltip!,
                      triggerMode: TooltipTriggerMode.manual,
                      showDuration: const Duration(seconds: 5),
                      child: Text(
                        widget.tooltip!,
                        style: theme.bodySmall.copyWith(
                          color: theme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                // Character counter
                Text(
                  '${widget.controller.text.length}/${widget.maxLength}',
                  style: theme.bodySmall.copyWith(
                    color: widget.controller.text.length == widget.maxLength
                        ? theme.error
                        : theme.secondaryText,
                  ),
                ),
              ],
            ),
          )
        // Show tooltip on focus (if maxLength is not set)
        else if (_showTooltip && widget.tooltip != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Tooltip(
              message: widget.tooltip!,
              triggerMode: TooltipTriggerMode.manual,
              showDuration: const Duration(seconds: 5),
              child: Text(
                widget.tooltip!,
                style: theme.bodySmall.copyWith(
                  color: theme.primary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension to make KeyboardTextInputWidget easier to use with common patterns
extension KeyboardTextInputWidgetExtension on KeyboardTextInputWidget {
  /// Create a password input field
  static KeyboardTextInputWidget password({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? placeholder,
    String? Function(String?)? validator,
    VoidCallback? onFieldSubmitted,
    String? tooltip,
  }) =>
      KeyboardTextInputWidget(
        label: label,
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder ?? 'Enter password',
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        tooltip: tooltip ?? 'Tab to next field, Shift+Tab to previous, Enter to submit',
      );

  /// Create an email input field
  static KeyboardTextInputWidget email({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? placeholder,
    String? Function(String?)? validator,
    VoidCallback? onFieldSubmitted,
    String? tooltip,
  }) =>
      KeyboardTextInputWidget(
        label: label,
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder ?? 'Enter email',
        keyboardType: TextInputType.emailAddress,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        tooltip: tooltip ?? 'Tab to next field, Shift+Tab to previous, Enter to submit',
      );

  /// Create a multi-line text area
  static KeyboardTextInputWidget textArea({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? placeholder,
    int maxLines = 4,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? tooltip,
  }) =>
      KeyboardTextInputWidget(
        label: label,
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        keyboardType: TextInputType.multiline,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        onChanged: onChanged,
        tooltip: tooltip ?? 'Shift+Tab to previous, Enter to add new line',
      );

  /// Create a number input field
  static KeyboardTextInputWidget number({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? placeholder,
    String? Function(String?)? validator,
    VoidCallback? onFieldSubmitted,
    String? tooltip,
  }) =>
      KeyboardTextInputWidget(
        label: label,
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder ?? 'Enter number',
        keyboardType: TextInputType.number,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        tooltip: tooltip ?? 'Tab to next field, Shift+Tab to previous, Enter to submit',
      );

  /// Create a phone input field
  static KeyboardTextInputWidget phone({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? placeholder,
    String? Function(String?)? validator,
    VoidCallback? onFieldSubmitted,
    String? tooltip,
  }) =>
      KeyboardTextInputWidget(
        label: label,
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder ?? 'Enter phone number',
        keyboardType: TextInputType.phone,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        tooltip: tooltip ?? 'Tab to next field, Shift+Tab to previous, Enter to submit',
      );
}
