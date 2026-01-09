import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/modals/keyboard_shortcuts_modal.dart';
import '/app_state.dart';

class UserMenu extends StatefulWidget {
  const UserMenu({
    super.key,
    this.userName = 'User',
    this.userEmail,
    this.userAvatarUrl,
    this.onLogout,
    this.onProfileTap,
  });

  final String userName;
  final String? userEmail;
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

  final List<MenuItemData> _menuItems = [
    MenuItemData(
      icon: Icons.person,
      label: 'Profile',
      value: 'profile',
    ),
    MenuItemData(
      icon: Icons.palette,
      label: 'Theme',
      value: 'theme',
      hasSubMenu: true,
    ),
    MenuItemData(
      icon: Icons.help_outline,
      label: 'Keyboard Shortcuts',
      value: 'help',
    ),
    MenuItemData(
      icon: Icons.logout,
      label: 'Logout',
      value: 'logout',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _menuFocusNode = FocusNode();
    _menuButtonFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _menuFocusNode.dispose();
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = FFAppState();

    return CompositedTransformTarget(
      link: _layerLink,
      child: RawKeyboardListener(
        focusNode: _menuButtonFocusNode,
        onKey: _handleMenuButtonKeyEvent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Menu button with user avatar
            GestureDetector(
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
                                _getInitials(widget.userName),
                                style: theme.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    // User name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.userName,
                          style: theme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.userEmail != null)
                          Text(
                            widget.userEmail!,
                            style: theme.bodySmall.copyWith(
                              color: theme.secondaryText,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
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
            // Dropdown menu
            if (_isMenuOpen) ...[
              const SizedBox(height: 8),
              RawKeyboardListener(
                focusNode: _menuFocusNode,
                onKey: _handleMenuKeyEvent,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.alternate,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_menuItems.length, (index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedMenuIndex == index;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (index > 0)
                            Divider(
                              height: 1,
                              color: theme.alternate,
                            ),
                          InkWell(
                            onTap: () => _handleMenuItemTap(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              color: isSelected
                                  ? theme.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: isSelected
                                        ? theme.primary
                                        : theme.secondaryText,
                                  ),
                                  const SizedBox(width: 12),
                                  if (item.value == 'theme') ...[
                                    Text(
                                      item.label,
                                      style: theme.bodyMedium.copyWith(
                                        color: isSelected
                                            ? theme.primary
                                            : theme.primaryText,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        appState.isLightMode
                                            ? 'Light'
                                            : 'Dark',
                                        style: theme.bodySmall.copyWith(
                                          color: theme.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      item.label,
                                      style: theme.bodyMedium.copyWith(
                                        color: isSelected
                                            ? theme.primary
                                            : theme.primaryText,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length > 0 ? name[0].toUpperCase() : 'U';
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _selectedMenuIndex = -1;
      if (_isMenuOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _menuFocusNode.requestFocus();
          setState(() => _selectedMenuIndex = 0);
        });
      }
    });
  }

  void _handleMenuButtonKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Tab to menu
      if (event.logicalKey == LogicalKeyboardKey.tab &&
          !event.isShiftPressed) {
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

  void _handleMenuKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Arrow down to navigate
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (_selectedMenuIndex < _menuItems.length - 1) {
            _selectedMenuIndex++;
          }
        });
      }

      // Arrow up to navigate
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (_selectedMenuIndex > 0) {
            _selectedMenuIndex--;
          } else {
            _isMenuOpen = false;
            _menuButtonFocusNode.requestFocus();
          }
        });
      }

      // Enter to select
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selectedMenuIndex >= 0) {
          _handleMenuItemTap(_selectedMenuIndex);
        }
      }

      // Escape to close
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() {
          _isMenuOpen = false;
          _selectedMenuIndex = -1;
        });
      }
    }
  }

  void _handleMenuItemTap(int index) {
    final item = _menuItems[index];

    switch (item.value) {
      case 'profile':
        widget.onProfileTap?.call();
        setState(() {
          _isMenuOpen = false;
          _selectedMenuIndex = -1;
        });
        break;
      case 'theme':
        _toggleTheme();
        break;
      case 'help':
        Navigator.pop(context);
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

  void _toggleTheme() async {
    final appState = FFAppState();
    final newLightMode = !appState.isLightMode;

    // Update app state and save to secure storage
    appState.setThemeMode(newLightMode);

    // Rebuild theme
    if (mounted) {
      setState(() {});
      // Trigger app rebuild - this depends on your app state management
      // If using Provider or similar, dispatch a theme change event
    }
  }

  void _logout() async {
    final appState = FFAppState();

    // Clear app state
    appState.setThemeMode(true);
    appState.currentUser = null;
    await appState.secureStorage.delete(key: 'auth_token');

    if (mounted) {
      // Navigate to sign-in page
      // The exact route depends on your app's navigation setup
      // For now, just pop to previous screen
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Or if using GoRouter:
      // context.go('/sign-in');
    }
  }
}

class MenuItemData {
  final IconData icon;
  final String label;
  final String value;
  final bool hasSubMenu;

  MenuItemData({
    required this.icon,
    required this.label,
    required this.value,
    this.hasSubMenu = false,
  });
}
