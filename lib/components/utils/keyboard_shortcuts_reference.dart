/// Centralized keyboard shortcuts reference for the entire application
/// Organize shortcuts by category for easy discovery and UI display
class KeyboardShortcut {
  final String key;
  final String description;
  final String category;
  final bool isModifier;

  KeyboardShortcut({
    required this.key,
    required this.description,
    required this.category,
    this.isModifier = false,
  });
}

class KeyboardShortcutsReference {
  static const String categoryGlobal = 'Global';
  static const String categoryNavigation = 'Navigation';
  static const String categorySearch = 'Search & Filter';
  static const String categoryContent = 'Content Management';
  static const String categoryModal = 'Modal Navigation';
  static const String categoryTheme = 'Theme & Settings';

  static final List<KeyboardShortcut> allShortcuts = [
    // Global shortcuts
    KeyboardShortcut(
      key: 'Ctrl + ?',
      description: 'Show keyboard shortcuts help',
      category: categoryGlobal,
    ),
    KeyboardShortcut(
      key: 'Ctrl + K',
      description: 'Focus search modal',
      category: categoryGlobal,
    ),
    KeyboardShortcut(
      key: 'Ctrl + E',
      description: 'Open export dialog',
      category: categoryGlobal,
    ),
    KeyboardShortcut(
      key: 'Tab',
      description: 'Move to next interactive element',
      category: categoryGlobal,
    ),
    KeyboardShortcut(
      key: 'Shift + Tab',
      description: 'Move to previous interactive element',
      category: categoryGlobal,
    ),

    // Navigation shortcuts
    KeyboardShortcut(
      key: 'Ctrl + Home',
      description: 'Go to home page',
      category: categoryNavigation,
    ),
    KeyboardShortcut(
      key: 'Alt + Left Arrow',
      description: 'Navigate back',
      category: categoryNavigation,
    ),
    KeyboardShortcut(
      key: 'Alt + Right Arrow',
      description: 'Navigate forward',
      category: categoryNavigation,
    ),
    KeyboardShortcut(
      key: 'Ctrl + L',
      description: 'Focus on sidebar/book list',
      category: categoryNavigation,
    ),

    // Search & Filter shortcuts
    KeyboardShortcut(
      key: 'Ctrl + F',
      description: 'Open search modal (text mode)',
      category: categorySearch,
    ),
    KeyboardShortcut(
      key: 'Ctrl + Shift + F',
      description: 'Open search modal (number mode)',
      category: categorySearch,
    ),
    KeyboardShortcut(
      key: '↓ Arrow',
      description: 'Navigate search results down',
      category: categorySearch,
    ),
    KeyboardShortcut(
      key: '↑ Arrow',
      description: 'Navigate search results up',
      category: categorySearch,
    ),
    KeyboardShortcut(
      key: 'Enter',
      description: 'Open selected search result',
      category: categorySearch,
    ),

    // Content Management
    KeyboardShortcut(
      key: 'Ctrl + A',
      description: 'Select all items in current view',
      category: categoryContent,
    ),
    KeyboardShortcut(
      key: 'Ctrl + D',
      description: 'Delete selected items',
      category: categoryContent,
    ),
    KeyboardShortcut(
      key: 'Ctrl + C',
      description: 'Copy selected items',
      category: categoryContent,
    ),
    KeyboardShortcut(
      key: 'Ctrl + V',
      description: 'Paste clipboard content',
      category: categoryContent,
    ),
    KeyboardShortcut(
      key: 'Delete',
      description: 'Delete current item / Remove from selection',
      category: categoryContent,
    ),
    KeyboardShortcut(
      key: 'Space',
      description: 'Toggle selection of current item',
      category: categoryContent,
    ),

    // Modal Navigation
    KeyboardShortcut(
      key: 'Escape',
      description: 'Close current modal/dropdown',
      category: categoryModal,
    ),
    KeyboardShortcut(
      key: '↓ Arrow',
      description: 'Navigate menu items down',
      category: categoryModal,
    ),
    KeyboardShortcut(
      key: '↑ Arrow',
      description: 'Navigate menu items up',
      category: categoryModal,
    ),
    KeyboardShortcut(
      key: 'Enter',
      description: 'Select highlighted menu item',
      category: categoryModal,
    ),
    KeyboardShortcut(
      key: 'Tab',
      description: 'Navigate between dialog buttons/fields',
      category: categoryModal,
    ),

    // Theme & Settings
    KeyboardShortcut(
      key: 'Ctrl + Shift + L',
      description: 'Toggle light/dark mode',
      category: categoryTheme,
    ),
    KeyboardShortcut(
      key: 'Alt + U',
      description: 'Open user menu',
      category: categoryTheme,
    ),
  ];

  /// Get shortcuts organized by category
  static Map<String, List<KeyboardShortcut>> getShortcutsByCategory() {
    final Map<String, List<KeyboardShortcut>> organized = {};
    
    for (final shortcut in allShortcuts) {
      if (!organized.containsKey(shortcut.category)) {
        organized[shortcut.category] = [];
      }
      organized[shortcut.category]!.add(shortcut);
    }

    return organized;
  }

  /// Get shortcuts for a specific category
  static List<KeyboardShortcut> getShortcutsForCategory(String category) {
    return allShortcuts.where((s) => s.category == category).toList();
  }

  /// Search shortcuts by keyword
  static List<KeyboardShortcut> searchShortcuts(String query) {
    final lowerQuery = query.toLowerCase();
    return allShortcuts
        .where((s) =>
            s.key.toLowerCase().contains(lowerQuery) ||
            s.description.toLowerCase().contains(lowerQuery) ||
            s.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get all category names
  static List<String> getAllCategories() {
    return [
      categoryGlobal,
      categoryNavigation,
      categorySearch,
      categoryContent,
      categoryModal,
      categoryTheme,
    ];
  }

  /// Get category color for visual distinction
  static Map<String, int> getCategoryColor() {
    return {
      categoryGlobal: 0xFF6200EE, // Purple
      categoryNavigation: 0xFF03DAC6, // Teal
      categorySearch: 0xFF1F1F1F, // Blue
      categoryContent: 0xFFCF6679, // Pink
      categoryModal: 0xFFFFA500, // Orange
      categoryTheme: 0xFF4CAF50, // Green
    };
  }

  /// Get category icon for visual distinction
  static Map<String, String> getCategoryIcon() {
    return {
      categoryGlobal: '⌨️',
      categoryNavigation: '🧭',
      categorySearch: '🔍',
      categoryContent: '📝',
      categoryModal: '📋',
      categoryTheme: '🎨',
    };
  }
}
