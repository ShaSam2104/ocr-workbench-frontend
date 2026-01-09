import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  late FocusNode _cancelFocusNode;
  late FocusNode _confirmFocusNode;
  late FocusNode _dialogFocusNode;

  @override
  void initState() {
    super.initState();
    _cancelFocusNode = FocusNode();
    _confirmFocusNode = FocusNode();
    _dialogFocusNode = FocusNode();

    // Focus on Cancel button by default (safer)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cancelFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _cancelFocusNode.dispose();
    _confirmFocusNode.dispose();
    _dialogFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 576;

    return RawKeyboardListener(
      focusNode: _dialogFocusNode,
      onKey: _handleKeyEvent,
      child: Dialog(
        insetPadding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Container(
          width: isMobile ? double.infinity : 400,
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.title,
                  style: theme.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.message,
                  style: theme.bodyMedium.copyWith(
                    color: theme.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Focus(
                        focusNode: _cancelFocusNode,
                        onKey: (node, event) {
                          if (event.logicalKey == LogicalKeyboardKey.tab &&
                              !event.isShiftPressed) {
                            _confirmFocusNode.requestFocus();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: TextButton(
                          onPressed: _handleCancel,
                          child: Text(
                            widget.cancelText,
                            style: theme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Focus(
                        focusNode: _confirmFocusNode,
                        onKey: (node, event) {
                          if (event.logicalKey == LogicalKeyboardKey.tab &&
                              event.isShiftPressed) {
                            _cancelFocusNode.requestFocus();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: ElevatedButton(
                          onPressed: _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                widget.confirmButtonColor ?? theme.error,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            widget.confirmText,
                            style: theme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Keyboard hint
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                child: Text(
                  'Tab to navigate  Enter to confirm  Esc to cancel',
                  style: theme.bodySmall.copyWith(
                    color: theme.secondaryText,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Escape to cancel
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleCancel();
      }

      // Enter to confirm
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleConfirm();
      }

      // Tab to navigate between buttons
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (event.isShiftPressed) {
          // Shift+Tab: go to previous (Cancel)
          _cancelFocusNode.requestFocus();
        } else {
          // Tab: go to next (Confirm)
          _confirmFocusNode.requestFocus();
        }
      }
    }
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    Navigator.of(context).pop(false);
  }

  void _handleConfirm() {
    widget.onConfirm();
    Navigator.of(context).pop(true);
  }
}
