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

  Color _getBackgroundColor() {
    return switch (type) {
      ToastType.success => const Color(0xFFDFF2D8),
      ToastType.error => const Color(0xFFF2DEDE),
      ToastType.info => const Color(0xFFD1ECF1),
      ToastType.warning => const Color(0xFFFCF8E3),
    };
  }

  Color _getBorderColor() {
    return switch (type) {
      ToastType.success => const Color(0xFFD6E9C6),
      ToastType.error => const Color(0xFFEBCCCC),
      ToastType.info => const Color(0xFFBCE8F1),
      ToastType.warning => const Color(0xFFFBEED5),
    };
  }

  Color _getIconColor() {
    return switch (type) {
      ToastType.success => const Color(0xFF3C763D),
      ToastType.error => const Color(0xFF8B3A3A),
      ToastType.info => const Color(0xFF31708F),
      ToastType.warning => const Color(0xFF8A6D3B),
    };
  }

  Color _getTextColor() {
    return switch (type) {
      ToastType.success => const Color(0xFF3C763D),
      ToastType.error => const Color(0xFF8B3A3A),
      ToastType.info => const Color(0xFF31708F),
      ToastType.warning => const Color(0xFF8A6D3B),
    };
  }

  IconData _getIconData() {
    return switch (type) {
      ToastType.success => Icons.check_circle,
      ToastType.error => Icons.error,
      ToastType.info => Icons.info,
      ToastType.warning => Icons.warning,
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
    return Container(
      constraints: BoxConstraints(
        maxWidth: 400,
        minWidth: 300,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              _getIconData(),
              color: _getIconColor(),
              size: 20,
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
                      color: _getTextColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: _getTextColor().withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Close button
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: _getIconColor().withValues(alpha: 0.6),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
