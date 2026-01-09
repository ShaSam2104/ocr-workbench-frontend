import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/focus_manager.dart';

class SearchBarComponent extends StatefulWidget {
  /// Callback when search is performed
  final Function(String) onSearch;

  /// Callback when search is cleared
  final Function()? onClear;

  /// Text editing controller
  final TextEditingController? controller;

  /// Focus node for keyboard navigation
  final FocusNode? focusNode;

  /// Whether to show dropdown suggestions
  final bool showDropdown;

  /// List of suggestions
  final List<String>? suggestions;

  /// Placeholder text
  final String placeholder;

  /// Help text or additional info
  final String? helpText;

  const SearchBarComponent({
    Key? key,
    required this.onSearch,
    this.onClear,
    this.controller,
    this.focusNode,
    this.showDropdown = false,
    this.suggestions,
    this.placeholder = 'Search...',
    this.helpText,
  }) : super(key: key);

  @override
  State<SearchBarComponent> createState() => _SearchBarComponentState();
}

class _SearchBarComponentState extends State<SearchBarComponent> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showDropdown = false;
  int _selectedSuggestionIndex = -1;
  List<String> _filteredSuggestions = [];
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onSearchChange);
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onSearchChange() {
    if (widget.suggestions != null && _controller.text.isNotEmpty) {
      setState(() {
        _filteredSuggestions = widget.suggestions!
            .where((suggestion) => suggestion
                .toLowerCase()
                .contains(_controller.text.toLowerCase()))
            .take(5)
            .toList();
        _showDropdown = _filteredSuggestions.isNotEmpty;
        _selectedSuggestionIndex = -1;
      });
    } else {
      setState(() {
        _showDropdown = false;
        _filteredSuggestions = [];
        _selectedSuggestionIndex = -1;
      });
    }
    widget.onSearch(_controller.text);
  }

  void _handleKeyEvent(KeyEvent event) {
    // Ctrl/Cmd + K to focus search
    if ((HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed) &&
        HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.keyK)) {
      _focusNode.requestFocus();
      return;
    }

    // Arrow down to navigate suggestions
    if (HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.arrowDown) &&
        _showDropdown) {
      setState(() {
        if (_selectedSuggestionIndex < _filteredSuggestions.length - 1) {
          _selectedSuggestionIndex++;
        }
      });
      return;
    }

    // Arrow up to navigate suggestions
    if (HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.arrowUp) &&
        _showDropdown) {
      setState(() {
        if (_selectedSuggestionIndex > 0) {
          _selectedSuggestionIndex--;
        }
      });
      return;
    }

    // Enter to select suggestion or submit search
    if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
      if (_showDropdown && _selectedSuggestionIndex >= 0) {
        _selectSuggestion(_filteredSuggestions[_selectedSuggestionIndex]);
      } else if (_controller.text.isNotEmpty) {
        widget.onSearch(_controller.text);
        _hideDropdown();
      }
      return;
    }

    // Escape to close dropdown
    if (HardwareKeyboard.instance
        .isLogicalKeyPressed(LogicalKeyboardKey.escape)) {
      _hideDropdown();
      return;
    }

    // Backspace or Delete to clear (optional behavior)
    if ((HardwareKeyboard.instance
                .isLogicalKeyPressed(LogicalKeyboardKey.backspace) ||
            HardwareKeyboard.instance
                .isLogicalKeyPressed(LogicalKeyboardKey.delete)) &&
        _controller.text.isEmpty) {
      _handleClear();
      return;
    }
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _controller.text = suggestion;
      _showDropdown = false;
      _selectedSuggestionIndex = -1;
      _filteredSuggestions = [];
    });
    widget.onSearch(suggestion);
  }

  void _handleClear() {
    setState(() {
      _controller.clear();
      _showDropdown = false;
      _filteredSuggestions = [];
      _selectedSuggestionIndex = -1;
    });
    widget.onClear?.call();
  }

  void _hideDropdown() {
    setState(() {
      _showDropdown = false;
      _selectedSuggestionIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input field with focus ring
        FocusRingDecorator.buildFocusRingContainer(
          isFocused: _isFocused,
          context: context,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  _handleKeyEvent(event);
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: theme.bodyMedium.copyWith(
                  color: theme.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: theme.bodyMedium.copyWith(
                    color: theme.secondaryText.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.search,
                      color: theme.primary,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: theme.primary,
                              size: 18,
                            ),
                            onPressed: _handleClear,
                            tooltip: 'Clear search (Esc)',
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.alternate,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.alternate,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Help text
        if (widget.helpText != null && widget.helpText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.helpText!,
              style: theme.bodySmall.copyWith(
                color: theme.secondaryText.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Suggestions dropdown
        if (_showDropdown && _filteredSuggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.alternate,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    final isSelected = index == _selectedSuggestionIndex;

                    return Container(
                      color: isSelected
                          ? theme.primary.withValues(alpha: 0.1)
                          : Colors.white,
                      child: InkWell(
                        onTap: () => _selectSuggestion(suggestion),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: theme.bodyMedium.copyWith(
                                    color: isSelected
                                        ? theme.primary
                                        : theme.primaryText,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.check,
                                    color: theme.primary,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

        // Keyboard shortcuts hint
        if (_isFocused && widget.helpText == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Ctrl+K to focus • ↑↓ to navigate • Enter to select • Esc to close',
              style: theme.bodySmall.copyWith(
                color: theme.primary.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
