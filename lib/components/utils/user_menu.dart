import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/modals/keyboard_shortcuts_modal.dart';
import '/app_state.dart';
import '/auth/custom_auth/auth_util.dart';

class UserMenu extends StatefulWidget {
  const UserMenu({
    super.key,
    this.userName,
    this.userAvatarUrl,
    this.onLogout,
    this.onProfileTap,
  });

  final String? userName;
  final String? userAvatarUrl;
  final VoidCallback? onLogout;
  final VoidCallback? onProfileTap;

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  late FocusNode _menuFocusNode;
  late FocusNode _menuButtonFocusNode;
  int _selectedMenuIndex = -1;
  bool _isMenuOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _menuFocusNode = FocusNode();
    _menuButtonFocusNode = FocusNode();
  }

  String _getUsernameFromToken() {
    try {
      final token = currentAuthenticationToken;
      if (token == null || token.isEmpty) return 'User';
      
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return 'User';
      
      // Decode payload (second part)
      final payload = parts[1];
      // Add padding if needed
      var normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;
      
      // Try different common JWT username fields
      return payloadMap['username'] as String? ??
             payloadMap['preferred_username'] as String? ??
             payloadMap['name'] as String? ??
             payloadMap['sub'] as String? ??
             'User';
    } catch (e) {
      print('Error decoding JWT: $e');
      return 'User';
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _menuFocusNode.dispose();
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        // Read theme and state fresh on each build
        final theme = FlutterFlowTheme.of(context);
        final appState = FFAppState();
        final isLightMode = appState.isLightMode;
        
        return Stack(
        children: [
          // Backdrop to close menu
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isMenuOpen = false;
                  _selectedMenuIndex = -1;
                });
                _removeOverlay();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Menu positioned below button
          Positioned(
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 8),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: Focus(
                  autofocus: true,
                  focusNode: _menuFocusNode,
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      _handleMenuKeyEvent(event);
                    }
                    return KeyEventResult.handled;
                  },
                  child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.alternate,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Theme section with Light/Dark
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: theme.alternate,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                                  child: Text(
                                    'Theme',
                                    style: theme.labelSmall.copyWith(
                                      color: theme.secondaryText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildThemeOption(
                                        'Light',
                                        Icons.wb_sunny_outlined,
                                        true,
                                        isLightMode,
                                        theme,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildThemeOption(
                                        'Dark',
                                        Icons.dark_mode_outlined,
                                        false,
                                        !isLightMode,
                                        theme,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Other menu items
                          _buildMenuItem(
                            'Keyboard Shortcuts',
                            Icons.keyboard_outlined,
                            'shortcuts',
                            2,
                            theme,
                          ),
                          _buildMenuItem(
                            'Logout',
                            Icons.logout_outlined,
                            'logout',
                            3,
                            theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
      },
    );
  }

  Widget _buildThemeOption(
    String label,
    IconData icon,
    bool isLightMode,
    bool isActive,
    FlutterFlowTheme theme,
  ) {
    return InkWell(
      onTap: () {
        FFAppState().setThemeMode(isLightMode);
        // Force the overlay to rebuild by marking it as needing rebuild
        _overlayEntry?.markNeedsBuild();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.primary.withValues(alpha: 0.12)
              : theme.primaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? theme.primary : theme.alternate,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? theme.primary : theme.secondaryText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.bodySmall.copyWith(
                color: isActive ? theme.primary : theme.primaryText,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String label,
    IconData icon,
    String value,
    int index,
    FlutterFlowTheme theme,
  ) {
    final isSelected = _selectedMenuIndex == index;
    final isLogout = value == 'logout';

    return InkWell(
      onTap: () => _handleMenuItemTap(index, value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        color: isSelected
            ? theme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isLogout
                  ? theme.error
                  : (isSelected ? theme.primary : theme.secondaryText),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.bodyMedium.copyWith(
                color: isLogout
                    ? theme.error
                    : (isSelected ? theme.primary : theme.primaryText),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        focusNode: _menuButtonFocusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            _handleMenuButtonKeyEvent(event);
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _toggleMenu,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _isMenuOpen
                  ? theme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primary,
                  ),
                  child: widget.userAvatarUrl != null
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.userAvatarUrl!),
                          backgroundColor: theme.primary,
                        )
                      : Center(
                          child: Text(
                            _getInitials(widget.userName ?? _getUsernameFromToken()),
                            style: theme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                // User name
                Text(
                  widget.userName ?? _getUsernameFromToken(),
                  style: theme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 4),
                // Dropdown indicator
                Icon(
                  _isMenuOpen ? Icons.expand_less : Icons.expand_more,
                  color: theme.secondaryText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _selectedMenuIndex = -1;
      
      if (_isMenuOpen) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _menuFocusNode.requestFocus();
        });
      } else {
        _removeOverlay();
      }
    });
  }

  void _handleMenuButtonKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Tab to menu
      if (event.logicalKey == LogicalKeyboardKey.tab &&
          !HardwareKeyboard.instance.isShiftPressed) {
        _menuButtonFocusNode.nextFocus();
      }

      // Enter/Space to open
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _toggleMenu();
      }

      // Arrow Down to open and focus first item
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (!_isMenuOpen) {
          _toggleMenu();
        }
      }
    }
  }

  void _handleMenuKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Arrow down to navigate
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          // Navigate between shortcuts (2) and logout (3)
          if (_selectedMenuIndex < 3) {
            _selectedMenuIndex++;
          }
        });
      }

      // Arrow up to navigate
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (_selectedMenuIndex > 2) {
            _selectedMenuIndex--;
          }
        });
      }

      // Enter to select
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selectedMenuIndex >= 2) {
          final values = ['theme-light', 'theme-dark', 'shortcuts', 'logout'];
          _handleMenuItemTap(_selectedMenuIndex, values[_selectedMenuIndex]);
        }
      }

      // Escape to close
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() {
          _isMenuOpen = false;
          _selectedMenuIndex = -1;
        });
        _removeOverlay();
      }
    }
  }

  void _handleMenuItemTap(int index, String value) {
    switch (value) {
      case 'shortcuts':
        setState(() {
          _isMenuOpen = false;
          _selectedMenuIndex = -1;
        });
        _removeOverlay();
        showDialog(
          context: context,
          builder: (context) => const KeyboardShortcutsModal(),
        );
        break;
      case 'logout':
        _logout();
        break;
    }
  }

  void _logout() async {
    setState(() {
      _isMenuOpen = false;
      _selectedMenuIndex = -1;
    });
    _removeOverlay();

    final appState = FFAppState();

    // Clear app state
    appState.setThemeMode(true);
    appState.currentUser = null;
    await appState.secureStorage.delete(key: 'auth_token');
    
    // Sign out from auth manager
    await authManager.signOut();

    // Call provided callback if any
    widget.onLogout?.call();

    if (mounted) {
      // Navigate to sign-in page using GoRouter
      context.go('/signInPage');
    }
  }
}

class MenuItemData {
  final IconData icon;
  final String label;
  final String value;

  MenuItemData({
    required this.icon,
    required this.label,
    required this.value,
  });
}
