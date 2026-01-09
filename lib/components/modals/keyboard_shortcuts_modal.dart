import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/utils/keyboard_shortcuts_reference.dart';

class KeyboardShortcutsModal extends StatefulWidget {
  const KeyboardShortcutsModal({super.key});

  @override
  State<KeyboardShortcutsModal> createState() => _KeyboardShortcutsModalState();
}

class _KeyboardShortcutsModalState extends State<KeyboardShortcutsModal> {
  late TextEditingController _searchController;
  List<KeyboardShortcut> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchResults = KeyboardShortcutsReference.allShortcuts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = KeyboardShortcutsReference.allShortcuts;
      } else {
        _searchResults = KeyboardShortcutsReference.searchShortcuts(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final categoryData = KeyboardShortcutsReference.getShortcutsByCategory();
    final categories = KeyboardShortcutsReference.getAllCategories();

    return Dialog(
      insetAnimationDuration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        child: Container(
          width: isMobile ? double.infinity : 900,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            minWidth: isMobile ? 300 : 600,
          ),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '⌨️ Keyboard Shortcuts',
                          style: theme.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Close (Escape)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search field
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search shortcuts... (Ctrl+F)',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.alternate),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.alternate),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _searchController.text.isNotEmpty
                        ? _buildSearchResults(theme)
                        : _buildCategoryView(theme, categoryData, categories),
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: theme.alternate),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_searchResults.length} shortcut${_searchResults.length != 1 ? 's' : ''}',
                      style: theme.bodySmall.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                    Text(
                      'Press Escape to close',
                      style: theme.bodySmall.copyWith(
                        color: theme.secondaryText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryView(
    FlutterFlowTheme theme,
    Map<String, List<KeyboardShortcut>> categoryData,
    List<String> categories,
  ) {
    final categoryColors = KeyboardShortcutsReference.getCategoryColor();
    final categoryIcons = KeyboardShortcutsReference.getCategoryIcon();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...categories.map((category) {
          final shortcuts = categoryData[category] ?? [];
          final colorValue = categoryColors[category] ?? 0xFF6200EE;
          final icon = categoryIcons[category] ?? '•';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Category header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: theme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 2,
                      width: 20,
                      color: Color(colorValue),
                    ),
                  ],
                ),
              ),
              // Shortcuts for this category
              ...shortcuts.map((shortcut) {
                return _buildShortcutRow(theme, shortcut);
              }),
              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSearchResults(FlutterFlowTheme theme) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: theme.secondaryText,
              ),
              const SizedBox(height: 12),
              Text(
                'No shortcuts found',
                style: theme.bodyMedium.copyWith(
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching for a different keyword',
                style: theme.bodySmall.copyWith(
                  color: theme.secondaryText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final categoryColors = KeyboardShortcutsReference.getCategoryColor();
    final categoryIcons = KeyboardShortcutsReference.getCategoryIcon();

    return Column(
      children: _searchResults.map((shortcut) {
        final colorValue = categoryColors[shortcut.category] ?? 0xFF6200EE;
        final icon = categoryIcons[shortcut.category] ?? '•';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(colorValue),
                  width: 3,
                ),
              ),
              color: theme.alternate.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shortcut.description,
                        style: theme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shortcut.category,
                        style: theme.bodySmall.copyWith(
                          color: theme.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(colorValue).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Color(colorValue),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    shortcut.key,
                    style: theme.bodySmall.copyWith(
                      color: Color(colorValue),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShortcutRow(FlutterFlowTheme theme, KeyboardShortcut shortcut) {
    final categoryColors = KeyboardShortcutsReference.getCategoryColor();
    final colorValue = categoryColors[shortcut.category] ?? 0xFF6200EE;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              shortcut.description,
              style: theme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Color(colorValue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Color(colorValue),
                width: 1,
              ),
            ),
            child: Text(
              shortcut.key,
              style: theme.bodySmall.copyWith(
                color: Color(colorValue),
                fontWeight: FontWeight.w600,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
