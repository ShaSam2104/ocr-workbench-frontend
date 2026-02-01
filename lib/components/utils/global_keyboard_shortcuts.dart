import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

/// Global keyboard shortcuts manager
class GlobalKeyboardShortcuts extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCtrlK;
  final VoidCallback? onCtrlE;
  final VoidCallback? onCtrlI;
  final VoidCallback? onCtrlF;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onShowHelp;

  const GlobalKeyboardShortcuts({
    super.key,
    required this.child,
    this.onCtrlK,
    this.onCtrlE,
    this.onCtrlI,
    this.onCtrlF,
    this.onToggleTheme,
    this.onShowHelp,
  });

  @override
  State<GlobalKeyboardShortcuts> createState() => _GlobalKeyboardShortcutsState();
}

class _GlobalKeyboardShortcutsState extends State<GlobalKeyboardShortcuts> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    print('🔧 Hardware keyboard handler registered');
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _focusNode.dispose();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    print('⌨️ RAW KEY EVENT: ${event.runtimeType} - ${event.logicalKey.keyLabel}');
    
    if (event is! KeyDownEvent) return false;

    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    final isModifierPressed = isMac 
        ? HardwareKeyboard.instance.isMetaPressed 
        : HardwareKeyboard.instance.isControlPressed;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    print('⌨️ Modifiers: Cmd/Ctrl=$isModifierPressed, Shift=$isShiftPressed');

    // Cmd/Ctrl + K
    if (isModifierPressed && !isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyK) {
      print('⌨️ Cmd/Ctrl+K detected!');
      widget.onCtrlK?.call();
      return true;
    }

    // Cmd/Ctrl + F or Cmd/Ctrl + Shift + F
    if (isModifierPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
      print('⌨️ Cmd/Ctrl+F detected!');
      widget.onCtrlF?.call();
      return true;
    }

    // Cmd/Ctrl + Shift + E
    if (isModifierPressed && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyE) {
      print('⌨️ Cmd/Ctrl+Shift+E detected!');
      widget.onCtrlE?.call();
      return true;
    }

    // Cmd/Ctrl + I
    if (isModifierPressed && !isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyI) {
      print('⌨️ Cmd/Ctrl+I detected!');
      widget.onCtrlI?.call();
      return true;
    }

    // Cmd/Ctrl + Shift + L
    if (isModifierPressed && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyL) {
      print('⌨️ Cmd/Ctrl+Shift+L detected!');
      widget.onToggleTheme?.call();
      return true;
    }

    // Cmd/Ctrl + Shift + ?
    if (isModifierPressed && isShiftPressed && event.logicalKey == LogicalKeyboardKey.slash) {
      print('⌨️ Cmd/Ctrl+Shift+? detected!');
      widget.onShowHelp?.call();
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    print('🔧 GlobalKeyboardShortcuts: Building widget');
    print('🔧 Platform: ${defaultTargetPlatform}');
    print('🔧 Callbacks registered: K=${widget.onCtrlK != null}, F=${widget.onCtrlF != null}, E=${widget.onCtrlE != null}, I=${widget.onCtrlI != null}, Theme=${widget.onToggleTheme != null}, Help=${widget.onShowHelp != null}');
    
    return widget.child;
  }
}

