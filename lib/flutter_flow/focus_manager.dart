import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'flutter_flow_theme.dart';

/// Manages keyboard navigation and focus node registration
class FocusNavigationHelper {
  final Map<String, FocusNode> _registeredFocusNodes = {};
  final List<String> _focusOrder = [];

  /// Registers a focus node with a unique identifier
  void registerFocusNode(String id, FocusNode node) {
    if (_registeredFocusNodes.containsKey(id)) {
      _registeredFocusNodes[id]?.dispose();
    }
    _registeredFocusNodes[id] = node;
    if (!_focusOrder.contains(id)) {
      _focusOrder.add(id);
    }
  }

  /// Retrieves a registered focus node by ID
  FocusNode? getFocusNode(String id) => _registeredFocusNodes[id];

  /// Moves focus to the next registered focus node
  void focusNext(String currentId) {
    final currentIndex = _focusOrder.indexOf(currentId);
    if (currentIndex == -1 || _focusOrder.isEmpty) return;

    final nextIndex = (currentIndex + 1) % _focusOrder.length;
    final nextId = _focusOrder[nextIndex];
    _registeredFocusNodes[nextId]?.requestFocus();
  }

  /// Moves focus to the previous registered focus node
  void focusPrevious(String currentId) {
    final currentIndex = _focusOrder.indexOf(currentId);
    if (currentIndex == -1 || _focusOrder.isEmpty) return;

    final previousIndex =
        (currentIndex - 1 + _focusOrder.length) % _focusOrder.length;
    final previousId = _focusOrder[previousIndex];
    _registeredFocusNodes[previousId]?.requestFocus();
  }

  /// Directly focuses a specific focus node by ID
  void focusById(String id) {
    _registeredFocusNodes[id]?.requestFocus();
  }

  /// Returns the ordered list of registered focus node IDs
  List<String> getFocusOrder() => List.unmodifiable(_focusOrder);

  /// Disposes all registered focus nodes
  void clearAll() {
    for (final node in _registeredFocusNodes.values) {
      node.dispose();
    }
    _registeredFocusNodes.clear();
    _focusOrder.clear();
  }

  /// Removes a specific focus node by ID
  void removeFocusNode(String id) {
    _registeredFocusNodes[id]?.dispose();
    _registeredFocusNodes.remove(id);
    _focusOrder.remove(id);
  }

  /// Returns the number of registered focus nodes
  int get focusNodeCount => _registeredFocusNodes.length;

  /// Checks if a focus node is registered
  bool hasFocusNode(String id) => _registeredFocusNodes.containsKey(id);
}

/// Handles focus ring decorations for text fields and other input widgets
class FocusRingDecorator {
  /// Adds a focus ring to an InputDecoration
  static InputDecoration addFocusRing(
    InputDecoration decoration,
    BuildContext context,
    bool isFocused,
  ) {
    final theme = FlutterFlowTheme.of(context);

    if (isFocused) {
      return decoration.copyWith(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.keyboardColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.error,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return decoration.copyWith(
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Returns a BoxDecoration with focus ring styling
  static BoxDecoration getFocusRingDecoration(
    bool isFocused,
    BuildContext context,
  ) {
    final theme = FlutterFlowTheme.of(context);

    return BoxDecoration(
      border: Border.all(
        color: isFocused ? theme.keyboardColor : theme.borderColor,
        width: isFocused ? 2.0 : 1.0,
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: isFocused
          ? [
              BoxShadow(
                color: theme.keyboardColor.withValues(alpha: 0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ]
          : [],
    );
  }

  /// Applies focus styling to a container with animated transition
  static Widget buildFocusRingContainer({
    required Widget child,
    required bool isFocused,
    required BuildContext context,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return AnimatedContainer(
      duration: duration,
      decoration: getFocusRingDecoration(isFocused, context),
      child: child,
    );
  }
}

/// Handles keyboard shortcuts and global keyboard events
class KeyboardShortcutHandler {
  final Map<_ShortcutKey, VoidCallback> _shortcuts = {};

  /// Registers a keyboard shortcut
  void registerShortcut(
    LogicalKeyboardKey key, {
    bool ctrlOrCmd = false,
    bool shift = false,
    bool alt = false,
    required VoidCallback onPressed,
  }) {
    final shortcutKey = _ShortcutKey(
      key: key,
      ctrlOrCmd: ctrlOrCmd,
      shift: shift,
      alt: alt,
    );
    _shortcuts[shortcutKey] = onPressed;
  }

  /// Unregisters a keyboard shortcut
  void unregisterShortcut(
    LogicalKeyboardKey key, {
    bool ctrlOrCmd = false,
    bool shift = false,
    bool alt = false,
  }) {
    final shortcutKey = _ShortcutKey(
      key: key,
      ctrlOrCmd: ctrlOrCmd,
      shift: shift,
      alt: alt,
    );
    _shortcuts.remove(shortcutKey);
  }

  /// Clears all registered shortcuts
  void clearAll() {
    _shortcuts.clear();
  }

  /// Handles a key event and executes matching shortcuts
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    for (final entry in _shortcuts.entries) {
      if (entry.key.matches(event)) {
        entry.value();
        return true;
      }
    }
    return false;
  }

  /// Returns a KeyboardListener widget that wraps the child
  Widget buildKeyboardListener({
    required Widget child,
    bool focusNode = true,
  }) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: handleKeyEvent,
      child: child,
    );
  }
}

/// Internal class to represent a keyboard shortcut key combination
class _ShortcutKey {
  final LogicalKeyboardKey key;
  final bool ctrlOrCmd;
  final bool shift;
  final bool alt;

  _ShortcutKey({
    required this.key,
    this.ctrlOrCmd = false,
    this.shift = false,
    this.alt = false,
  });

  bool matches(KeyEvent event) {
    if (event.logicalKey != key) return false;

    final isCtrlOrCmd =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    if (ctrlOrCmd != isCtrlOrCmd) return false;
    if (shift != isShift) return false;
    if (alt != isAlt) return false;

    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ShortcutKey &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          ctrlOrCmd == other.ctrlOrCmd &&
          shift == other.shift &&
          alt == other.alt;

  @override
  int get hashCode =>
      key.hashCode ^ ctrlOrCmd.hashCode ^ shift.hashCode ^ alt.hashCode;
}

/// Provides common keyboard shortcuts for navigation and editing
class StandardKeyboardShortcuts {
  /// Returns a KeyboardShortcutHandler configured with standard shortcuts
  static KeyboardShortcutHandler createStandardHandler({
    required VoidCallback onSubmit,
    required VoidCallback onCancel,
    required VoidCallback? onNext,
    required VoidCallback? onPrevious,
    required VoidCallback? onCopy,
    required VoidCallback? onPaste,
    required VoidCallback? onUndo,
    required VoidCallback? onRedo,
  }) {
    final handler = KeyboardShortcutHandler();

    // Standard navigation shortcuts
    handler.registerShortcut(
      LogicalKeyboardKey.enter,
      onPressed: onSubmit,
    );

    handler.registerShortcut(
      LogicalKeyboardKey.escape,
      onPressed: onCancel,
    );

    if (onNext != null) {
      handler.registerShortcut(
        LogicalKeyboardKey.tab,
        onPressed: onNext,
      );
    }

    if (onPrevious != null) {
      handler.registerShortcut(
        LogicalKeyboardKey.tab,
        shift: true,
        onPressed: onPrevious,
      );
    }

    // Standard editing shortcuts (Ctrl+C, Ctrl+V, Ctrl+Z, Ctrl+Y)
    if (onCopy != null) {
      handler.registerShortcut(
        LogicalKeyboardKey.keyC,
        ctrlOrCmd: true,
        onPressed: onCopy,
      );
    }

    if (onPaste != null) {
      handler.registerShortcut(
        LogicalKeyboardKey.keyV,
        ctrlOrCmd: true,
        onPressed: onPaste,
      );
    }

    if (onUndo != null) {
      handler.registerShortcut(
        LogicalKeyboardKey.keyZ,
        ctrlOrCmd: true,
        onPressed: onUndo,
      );
    }

    if (onRedo != null) {
      handler.registerShortcut(
        LogicalKeyboardKey.keyY,
        ctrlOrCmd: true,
        onPressed: onRedo,
      );
    }

    return handler;
  }
}

/// A widget that combines focus management with keyboard shortcuts
class KeyboardNavigationScope extends StatefulWidget {
  final Widget child;
  final FocusNavigationHelper? focusManager;
  final KeyboardShortcutHandler? shortcutHandler;
  final bool enableTabNavigation;

  const KeyboardNavigationScope({
    Key? key,
    required this.child,
    this.focusManager,
    this.shortcutHandler,
    this.enableTabNavigation = true,
  }) : super(key: key);

  @override
  State<KeyboardNavigationScope> createState() =>
      _KeyboardNavigationScopeState();

  static FocusNavigationHelper? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<KeyboardNavigationScope>()
        ?.focusManager;
  }
}

class _KeyboardNavigationScopeState extends State<KeyboardNavigationScope> {
  late FocusNavigationHelper _focusManager;
  late KeyboardShortcutHandler _shortcutHandler;
  late FocusNode _rootFocusNode;

  @override
  void initState() {
    super.initState();
    _focusManager = widget.focusManager ?? FocusNavigationHelper();
    _shortcutHandler = widget.shortcutHandler ?? KeyboardShortcutHandler();
    _rootFocusNode = FocusNode();

    if (widget.enableTabNavigation) {
      _setupTabNavigation();
    }
  }

  void _setupTabNavigation() {
    _shortcutHandler.registerShortcut(
      LogicalKeyboardKey.tab,
      onPressed: () {
        // Get the currently focused node
        final focusedId = _focusManager.getFocusOrder().firstWhere(
              (id) => _focusManager.getFocusNode(id)?.hasFocus ?? false,
              orElse: () => _focusManager.getFocusOrder().isNotEmpty
                  ? _focusManager.getFocusOrder().first
                  : '',
            );

        if (focusedId.isNotEmpty) {
          _focusManager.focusNext(focusedId);
        }
      },
    );

    _shortcutHandler.registerShortcut(
      LogicalKeyboardKey.tab,
      shift: true,
      onPressed: () {
        final focusedId = _focusManager.getFocusOrder().firstWhere(
              (id) => _focusManager.getFocusNode(id)?.hasFocus ?? false,
              orElse: () => _focusManager.getFocusOrder().isNotEmpty
                  ? _focusManager.getFocusOrder().first
                  : '',
            );

        if (focusedId.isNotEmpty) {
          _focusManager.focusPrevious(focusedId);
        }
      },
    );
  }

  @override
  void dispose() {
    _rootFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _rootFocusNode,
      onKeyEvent: _shortcutHandler.handleKeyEvent,
      child: widget.child,
    );
  }
}
