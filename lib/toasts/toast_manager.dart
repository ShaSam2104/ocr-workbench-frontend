import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/nav/nav.dart';

/// Toast manager for displaying toast notifications globally
/// Usage:
/// - ToastManager.showSuccess('Success message')
/// - ToastManager.showError('Error message')
/// - ToastManager.showInfo('Info message')
/// - ToastManager.showWarning('Warning message')
/// - ToastManager.clear()
class ToastManager {
  static OverlayEntry? _currentToastEntry;

  /// Initialize with a valid context that has an Overlay
  static void init(BuildContext context) {
    debugPrint('✅ ToastManager init called (using appNavigatorKey)');
  }

  /// Show a success toast
  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      message,
      ToastType.success,
      duration,
    );
  }

  /// Show an error toast
  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showToast(
      message,
      ToastType.error,
      duration,
    );
  }

  /// Show an info toast
  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      message,
      ToastType.info,
      duration,
    );
  }

  /// Show a warning toast
  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      message,
      ToastType.warning,
      duration,
    );
  }

  /// Clear/dismiss current toast
  static void clear() {
    _currentToastEntry?.remove();
    _currentToastEntry = null;
  }

  static void _showToast(
    String message,
    ToastType type,
    Duration duration,
  ) {
    try {
      // Remove existing toast
      clear();

      // Get NavigatorState from appNavigatorKey
      final navigatorState = appNavigatorKey.currentState;
      if (navigatorState == null) {
        debugPrint('❌ Toast ERROR: No NavigatorState available from appNavigatorKey');
        return;
      }

      // Get overlay from NavigatorState
      final overlayState = navigatorState.overlay;
      if (overlayState == null) {
        debugPrint('⚠️ NavigatorState has no overlay');
        return;
      }

      // Create new toast entry
      _currentToastEntry = OverlayEntry(
        builder: (context) => _AnimatedToastOverlay(
          message: message,
          type: type,
          duration: duration,
          onDismiss: clear,
        ),
      );

      // Insert into overlay
      overlayState.insert(_currentToastEntry!);

      // Auto-dismiss after duration
      Future.delayed(duration, () {
        clear();
      });
    } catch (e) {
      debugPrint('❌ ToastManager error: $e');
    }
  }
}

enum ToastType { success, error, info, warning }

class _AnimatedToastOverlay extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AnimatedToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToastOverlay> createState() => _AnimatedToastOverlayState();
}

class _AnimatedToastOverlayState extends State<_AnimatedToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _dismiss,
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (HardwareKeyboard.instance
                        .isLogicalKeyPressed(LogicalKeyboardKey.escape)) {
                      _dismiss();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: _ToastContent(
                    message: widget.message,
                    type: widget.type,
                    onDismiss: _dismiss,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastContent extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastContent({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  // Theme-aware color getters for premium look
  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (type) {
      ToastType.success => isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
      ToastType.error => isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2),
      ToastType.info => isDark ? const Color(0xFF0C4A6E) : const Color(0xFFEFF6FF),
      ToastType.warning => isDark ? const Color(0xFF78350F) : const Color(0xFFFFFBEB),
    };
  }

  Color _getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (type) {
      ToastType.success => isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5),
      ToastType.error => isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2),
      ToastType.info => isDark ? const Color(0xFF0E7490) : const Color(0xFFDBEAFE),
      ToastType.warning => isDark ? const Color(0xFF92400E) : const Color(0xFFFEF3C7),
    };
  }

  Color _getAccentColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (type) {
      ToastType.success => isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
      ToastType.error => isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
      ToastType.info => isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB),
      ToastType.warning => isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
    };
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (type) {
      ToastType.success => isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
      ToastType.error => isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B),
      ToastType.info => isDark ? const Color(0xFFBAE6FD) : const Color(0xFF1E40AF),
      ToastType.warning => isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
    };
  }

  IconData _getIconData() {
    return switch (type) {
      ToastType.success => Icons.check_circle_rounded,
      ToastType.error => Icons.error_rounded,
      ToastType.info => Icons.info_rounded,
      ToastType.warning => Icons.warning_rounded,
    };
  }

  String _getTitle() {
    return switch (type) {
      ToastType.success => 'Success',
      ToastType.error => 'Error',
      ToastType.info => 'Info',
      ToastType.warning => 'Warning',
    };
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(context);
    final textColor = _getTextColor(context);

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 420,
        minWidth: 320,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color accent bar
            Container(
              width: 4,
              constraints: const BoxConstraints(minHeight: 56),
              color: accentColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Icon with subtle background
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconData(),
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTitle(),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              decoration: TextDecoration.none,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onDismiss,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: textColor.withValues(alpha: 0.5),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
