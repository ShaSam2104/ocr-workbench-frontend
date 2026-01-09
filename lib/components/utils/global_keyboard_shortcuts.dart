import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/components/modals/keyboard_shortcuts_modal.dart';

/// Global keyboard shortcuts manager
/// Handles global app-wide keyboard shortcuts
/// 
/// Usage: Wrap your main content with this widget
/// Example:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return GlobalKeyboardShortcuts(
///     child: Scaffold(...),
///   );
/// }
/// ```
class GlobalKeyboardShortcuts extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCtrlK; // Called when Ctrl+K is pressed
  final VoidCallback? onCtrlE; // Called when Ctrl+E is pressed
  final VoidCallback? onCtrlF; // Called when Ctrl+F is pressed

  const GlobalKeyboardShortcuts({
    super.key,
    required this.child,
    this.onCtrlK,
    this.onCtrlE,
    this.onCtrlF,
  });

  @override
  State<GlobalKeyboardShortcuts> createState() =>
      _GlobalKeyboardShortcutsState();
}

class _GlobalKeyboardShortcutsState extends State<GlobalKeyboardShortcuts> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Ctrl + ? (Shift + /) - Show keyboard shortcuts help
      if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.slash) {
        _showKeyboardShortcutsModal();
      }

      // Ctrl + K - Focus search (custom callback)
      if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyK) {
        widget.onCtrlK?.call();
      }

      // Ctrl + E - Open export (custom callback)
      if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyE) {
        widget.onCtrlE?.call();
      }

      // Ctrl + F - Open search (custom callback)
      if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyF) {
        widget.onCtrlF?.call();
      }
    }
  }

  void _showKeyboardShortcutsModal() {
    showDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: widget.child,
    );
  }
}
