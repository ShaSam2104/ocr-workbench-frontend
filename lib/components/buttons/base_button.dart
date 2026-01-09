import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/focus_manager.dart';

class BaseButtonWidget extends StatefulWidget {
  /// The text label displayed on the button
  final String label;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Custom button style (overrides primary/secondary styling)
  final ButtonStyle? customStyle;

  /// Whether this is a primary button (true) or secondary (false)
  final bool isPrimary;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Whether the button should take full width
  final bool fullWidth;

  /// Padding around button content
  final EdgeInsets padding;

  /// Border radius of the button
  final double borderRadius;

  /// Focus node for keyboard navigation
  final FocusNode? focusNode;

  /// Tooltip text showing keyboard shortcut (e.g., "Ctrl+Enter to Submit")
  final String? tooltipText;

  const BaseButtonWidget({
    Key? key,
    required this.label,
    required this.onPressed,
    this.customStyle,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = 8,
    this.focusNode,
    this.tooltipText,
  }) : super(key: key);

  @override
  State<BaseButtonWidget> createState() => _BaseButtonWidgetState();
}

class _BaseButtonWidgetState extends State<BaseButtonWidget> {
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  void _handlePressed() {
    if (!widget.isLoading) {
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build button style based on isPrimary flag
    final buttonStyle = widget.customStyle ?? _buildButtonStyle(context);

    // Build button content
    final buttonContent = _buildButtonContent(context);

    // Build the button widget
    Widget button = SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _handlePressed,
        style: buttonStyle,
        child: buttonContent,
      ),
    );

    // Wrap with focus ring decorator
    button = FocusRingDecorator.buildFocusRingContainer(
      isFocused: _isFocused,
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: button,
      ),
    );

    // Wrap with keyboard handler
    button = FocusableActionDetector(
      focusNode: _internalFocusNode,
      onShowFocusHighlight: (show) {
        setState(() {
          _isFocused = show;
        });
      },
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): _ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): _ActivateIntent(),
      },
      actions: {
        _ActivateIntent: CallbackAction<_ActivateIntent>(
          onInvoke: (_) {
            _handlePressed();
            return null;
          },
        ),
      },
      child: button,
    );

    // Wrap with tooltip if provided
    if (widget.tooltipText != null && widget.tooltipText!.isNotEmpty) {
      button = Tooltip(
        message: widget.tooltipText!,
        triggerMode: TooltipTriggerMode.manual,
        showDuration: const Duration(milliseconds: 3000),
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    // Show loading indicator if isLoading
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isPrimary ? Colors.white : theme.primary,
          ),
        ),
      );
    }

    // Build content with optional icon
    if (widget.icon != null) {
      return Padding(
        padding: widget.padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon),
            const SizedBox(width: 8),
            Text(widget.label),
          ],
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: Text(widget.label),
    );
  }

  ButtonStyle _buildButtonStyle(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (widget.isPrimary) {
      return ElevatedButton.styleFrom(
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: theme.primary.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        elevation: 2,
      );
    } else {
      return OutlinedButton.styleFrom(
        foregroundColor: theme.primary,
        side: BorderSide(
          color: theme.primary,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          theme.primary.withValues(alpha: 0.1),
        ),
      );
    }
  }
}

/// Intent for button activation via keyboard (Enter or Space)
class _ActivateIntent extends Intent {
  const _ActivateIntent();
}

/// Extension to make BaseButtonWidget easier to use with common patterns
extension BaseButtonWidgetExtension on BaseButtonWidget {
  /// Create a primary button with full width (useful for forms)
  static BaseButtonWidget primaryFullWidth({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    FocusNode? focusNode,
    String? tooltipText,
  }) =>
      BaseButtonWidget(
        label: label,
        onPressed: onPressed,
        isPrimary: true,
        fullWidth: true,
        isLoading: isLoading,
        icon: icon,
        focusNode: focusNode,
        tooltipText: tooltipText,
      );

  /// Create a secondary button with full width
  static BaseButtonWidget secondaryFullWidth({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    FocusNode? focusNode,
    String? tooltipText,
  }) =>
      BaseButtonWidget(
        label: label,
        onPressed: onPressed,
        isPrimary: false,
        fullWidth: true,
        isLoading: isLoading,
        icon: icon,
        focusNode: focusNode,
        tooltipText: tooltipText,
      );

  /// Create a compact primary button (small padding)
  static BaseButtonWidget compactPrimary({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    FocusNode? focusNode,
    String? tooltipText,
  }) =>
      BaseButtonWidget(
        label: label,
        onPressed: onPressed,
        isPrimary: true,
        isLoading: isLoading,
        icon: icon,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        focusNode: focusNode,
        tooltipText: tooltipText,
      );

  /// Create a compact secondary button
  static BaseButtonWidget compactSecondary({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    FocusNode? focusNode,
    String? tooltipText,
  }) =>
      BaseButtonWidget(
        label: label,
        onPressed: onPressed,
        isPrimary: false,
        isLoading: isLoading,
        icon: icon,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        focusNode: focusNode,
        tooltipText: tooltipText,
      );

  /// Create an icon button with label
  static BaseButtonWidget withIcon({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = true,
    bool isLoading = false,
    FocusNode? focusNode,
    String? tooltipText,
  }) =>
      BaseButtonWidget(
        label: label,
        onPressed: onPressed,
        icon: icon,
        isPrimary: isPrimary,
        isLoading: isLoading,
        focusNode: focusNode,
        tooltipText: tooltipText,
      );
}
