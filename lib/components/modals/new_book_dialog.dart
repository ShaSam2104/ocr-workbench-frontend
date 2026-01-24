import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';
import '/enums/language.dart';

class NewBookDialog extends StatefulWidget {
  final Function(int bookId, String name) onCreated;

  const NewBookDialog({
    super.key,
    required this.onCreated,
  });

  @override
  State<NewBookDialog> createState() => _NewBookDialogState();
}

class _NewBookDialogState extends State<NewBookDialog> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isCreating = false;
  String? _errorMessage;
  bool _hasNameError = false;
  
  // Language selection using enum
  late Map<LanguageCode, bool> _selectedLanguages;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    
    // Initialize language selection with enum
    _selectedLanguages = {
      LanguageCode.english: true,
      LanguageCode.hindi: false,
      LanguageCode.sanskrit: false,
    };
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
    
    _nameController.addListener(() {
      if (_hasNameError && _nameController.text.trim().isNotEmpty) {
        setState(() => _hasNameError = false);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _hasNameError = true);
      return;
    }

    // Get selected languages using enum codes
    final selectedLangs = _selectedLanguages.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.code)
        .toList();
    
    if (selectedLangs.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one language');
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final authToken = currentAuthenticationToken ?? '';
      
      final response = await OCRWorkbenchAPIGroup.createBookCall.call(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        hTTPBearer: authToken,
        languagesList: selectedLangs,
      );

      if (response.succeeded) {
        final bookId = response.jsonBody['id'] as int;
        final bookName = response.jsonBody['name'] as String;
        
        if (mounted) {
          widget.onCreated(bookId, bookName);
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _isCreating = false;
          _errorMessage = 'Failed to create book. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
        _errorMessage = 'Network error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 520,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header - Notion style (clean, minimal)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Book',
                        style: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .override(
                              fontFamily: 'Inter',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                      ),
                      InkWell(
                        onTap: _isCreating ? null : () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close,
                            size: 18.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
                ),
                
                // Body
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Name
                      Text(
                        'Name',
                        style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Inter',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              fontSize: 14.0,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                        decoration: InputDecoration(
                          hintText: 'Untitled',
                          hintStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: 14.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText
                                        .withOpacity(0.4),
                                  ),
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: _hasNameError
                                  ? FlutterFlowTheme.of(context).error
                                  : FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: _hasNameError
                                  ? FlutterFlowTheme.of(context).error
                                  : FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: _hasNameError
                                  ? FlutterFlowTheme.of(context).error
                                  : FlutterFlowTheme.of(context).primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 10.0),
                        ),
                        onSubmitted: (_) => _handleCreate(),
                      ),
                      if (_hasNameError)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Name is required',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: 'Inter',
                                  fontSize: 12.0,
                                  color: FlutterFlowTheme.of(context).error,
                                ),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      
                      // Description
                      Text(
                        'Description',
                        style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Inter',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              fontSize: 14.0,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                        decoration: InputDecoration(
                          hintText: 'Add a description...',
                          hintStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: 14.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText
                                        .withOpacity(0.4),
                                  ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 10.0),
                        ),
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Languages
                      Text(
                        'Languages',
                        style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Inter',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                      ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: LanguageCode.values.map((language) {
                          final isSelected = _selectedLanguages[language] ?? false;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedLanguages[language] = !isSelected;
                              });
                            },
                            borderRadius: BorderRadius.circular(4.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                                    : FlutterFlowTheme.of(context).secondaryBackground,
                                border: Border.all(
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4.0),
                                      child: Icon(
                                        Icons.check,
                                        size: 14.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  Text(
                                    language.displayName,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 13.0,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: isSelected
                                              ? FlutterFlowTheme.of(context).primary
                                              : FlutterFlowTheme.of(context).secondaryText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .error
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .error
                                    .withOpacity(0.2),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16.0,
                                  color: FlutterFlowTheme.of(context).error,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 12.0,
                                          color: FlutterFlowTheme.of(context).error,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Actions - Notion style
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isCreating
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          TextButton(
                            onPressed: _isCreating ? null : _handleCreate,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              backgroundColor: _nameController.text.trim().isEmpty || _isCreating
                                  ? FlutterFlowTheme.of(context).alternate.withOpacity(0.5)
                                  : FlutterFlowTheme.of(context).primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: _isCreating
                                ? const SizedBox(
                                    width: 76.0,
                                    height: 16.0,
                                    child: Center(
                                      child: SizedBox(
                                        width: 14.0,
                                        height: 14.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Create',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
