import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';
import '/flutter_flow/flutter_flow_theme.dart';

class FileForPreview {
  String id;
  String name;
  Uint8List imageBytes;
  bool isSelected;
  bool hasCropped;
  String? originalFileName;

  FileForPreview({
    required this.id,
    required this.name,
    required this.imageBytes,
    this.isSelected = true,
    this.hasCropped = false,
    this.originalFileName,
  });
}

class ImagePreviewCropModal extends StatefulWidget {
  final List<FileForPreview> initialFiles;
  final VoidCallback onClose;
  final Function(List<FileForPreview>) onConfirm;

  const ImagePreviewCropModal({
    Key? key,
    required this.initialFiles,
    required this.onClose,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<ImagePreviewCropModal> createState() => _ImagePreviewCropModalState();
}

class _ImagePreviewCropModalState extends State<ImagePreviewCropModal> {
  late List<FileForPreview> _files;
  bool _isProcessing = false;
  int? _currentCropIndex;
  final _cropController = CropController();

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.initialFiles);
  }

  @override
  void dispose() {
    // CropController doesn't have dispose method in version 1.0.2
    super.dispose();
  }

  void _startCrop(int index) {
    setState(() {
      _currentCropIndex = index;
    });
  }

  void _cancelCrop() {
    setState(() {
      _currentCropIndex = null;
    });
  }

  void _onCropped(CropResult result) {
    if (_currentCropIndex != null) {
      if (result is CropSuccess) {
        setState(() {
          _files[_currentCropIndex!].imageBytes = result.croppedImage;
          _files[_currentCropIndex!].hasCropped = true;
          _currentCropIndex = null;
        });
      } else if (result is CropFailure) {
        // Handle crop failure
        _cancelCrop();
      }
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      _files[index].isSelected = !_files[index].isSelected;
    });
  }

  void _selectAll() {
    setState(() {
      for (var file in _files) {
        file.isSelected = true;
      }
    });
  }

  void _deselectAll() {
    setState(() {
      for (var file in _files) {
        file.isSelected = false;
      }
    });
  }

  void _selectRange(int start, int end) {
    if (start < 1 || end > _files.length || start > end) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid range. Please check your input.')),
      );
      return;
    }

    setState(() {
      // Deselect all first
      for (var file in _files) {
        file.isSelected = false;
      }
      // Select the range (convert to 0-based index)
      for (int i = start - 1; i < end; i++) {
        _files[i].isSelected = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected files $start to $end')),
    );
  }

  void _showRangeSelectionDialog() {
    final currentTheme = FlutterFlowTheme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _RangeSelectionDialog(
        fileCount: _files.length,
        onConfirm: (start, end) {
          _selectRange(start, end);
        },
        theme: currentTheme,
      ),
    );
  }

  Widget _buildMinimalButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required FlutterFlowTheme theme,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final selectedCount = _files.where((f) => f.isSelected).length;

    // Show crop view if an image is selected for cropping
    if (_currentCropIndex != null) {
      return Dialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Crop Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Crop Image',
                      style: theme.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelCrop,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.alternate,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: theme.secondaryText,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: theme.alternate, height: 1),
              // Crop Area
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Crop(
                    controller: _cropController,
                    image: _files[_currentCropIndex!].imageBytes,
                    onCropped: _onCropped,
                    withCircleUi: false,
                    maskColor: Colors.black.withValues(alpha: 0.7),
                    cornerDotBuilder: (size, edgeAlignment) => DotControl(
                      color: theme.primary,
                    ),
                    progressIndicator: CircularProgressIndicator(
                      color: theme.primary,
                    ),
                  ),
                ),
              ),
              Divider(color: theme.alternate, height: 1),
              // Crop Actions
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _cancelCrop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.alternate,
                        foregroundColor: theme.secondaryText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: theme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _cropController.crop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Crop',
                        style: theme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show preview grid
    return Dialog(
      backgroundColor: theme.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview & Crop Images',
                        style: theme.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click crop button to edit • Tap to select/deselect',
                        style: theme.bodySmall.copyWith(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.alternate,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        color: theme.secondaryText,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.alternate, height: 1),
            // Selection controls - minimal and elegant
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  // Selection status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$selectedCount / ${_files.length}',
                          style: theme.labelMedium.copyWith(
                            color: theme.primaryText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Minimal selection buttons with icons only
                  Row(
                    children: [
                      _buildMinimalButton(
                        icon: Icons.done_all,
                        tooltip: 'Select All',
                        onTap: _selectAll,
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      _buildMinimalButton(
                        icon: Icons.remove_done,
                        tooltip: 'Deselect All',
                        onTap: _deselectAll,
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      _buildMinimalButton(
                        icon: Icons.low_priority,
                        tooltip: 'Select Range',
                        onTap: _showRangeSelectionDialog,
                        theme: theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: theme.alternate, height: 1),
            // Grid of thumbnails
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    return _buildThumbnailTile(file, index, theme);
                  },
                ),
              ),
            ),
            Divider(color: theme.alternate, height: 1),
            // Footer with actions
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$selectedCount of ${_files.length} selected',
                    style: theme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isProcessing ? null : widget.onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.alternate,
                          foregroundColor: theme.secondaryText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: theme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed:
                            _isProcessing || selectedCount == 0
                                ? null
                                : () {
                                  final selectedFiles =
                                      _files
                                          .where((f) => f.isSelected)
                                          .toList();
                                  widget.onConfirm(selectedFiles);
                                  Navigator.of(context).pop();
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                            : Text(
                              'Continue ($selectedCount)',
                              style: theme.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildThumbnailTile(
    FileForPreview file,
    int index,
    FlutterFlowTheme theme,
  ) {
    return GestureDetector(
      onTap: () => _toggleSelection(index),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Thumbnail image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: file.isSelected ? theme.primary : theme.alternate,
                      width: file.isSelected ? 3 : 1,
                    ),
                    color: theme.alternate,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.memory(
                          file.imageBytes,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        // File number overlay
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Selection checkbox
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: file.isSelected ? theme.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            file.isSelected ? theme.primary : theme.alternate,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: file.isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : const SizedBox(width: 16, height: 16),
                  ),
                ),
                // Crop indicator
                if (file.hasCropped)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Cropped',
                            style: theme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Crop button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startCrop(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.alternate,
                foregroundColor: theme.secondaryText,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: Icon(Icons.crop, size: 16),
              label: Text(
                'Crop',
                style: theme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom range selection dialog widget
class _RangeSelectionDialog extends StatefulWidget {
  final int fileCount;
  final Function(int, int) onConfirm;
  final FlutterFlowTheme theme;

  const _RangeSelectionDialog({
    required this.fileCount,
    required this.onConfirm,
    required this.theme,
  });

  @override
  State<_RangeSelectionDialog> createState() => _RangeSelectionDialogState();
}

class _RangeSelectionDialogState extends State<_RangeSelectionDialog> {
  late TextEditingController _startController;
  late TextEditingController _endController;
  late FocusNode _startFocus;
  late FocusNode _endFocus;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController();
    _endController = TextEditingController();
    _startFocus = FocusNode();
    _endFocus = FocusNode();

    // Pre-fill with all files selected
    _startController.text = '1';
    _endController.text = widget.fileCount.toString();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _startFocus.dispose();
    _endFocus.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final start = int.tryParse(_startController.text);
    final end = int.tryParse(_endController.text);

    if (start != null && end != null) {
      if (start >= 1 && end <= widget.fileCount && start <= end) {
        Navigator.of(context).pop();
        widget.onConfirm(start, end);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid range. Please enter values between 1 and ${widget.fileCount}'),
            backgroundColor: widget.theme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 380,
        decoration: BoxDecoration(
          color: widget.theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.theme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.format_list_numbered,
                      color: widget.theme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Range',
                          style: widget.theme.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose files ${widget.fileCount > 1 ? '1-${widget.fileCount}' : '1'}',
                          style: widget.theme.bodySmall.copyWith(
                            color: widget.theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(
              color: widget.theme.alternate,
              height: 1,
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildRangeInput(
                      controller: _startController,
                      focusNode: _startFocus,
                      label: 'From',
                      hintText: '1',
                      theme: widget.theme,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.arrow_forward,
                      color: widget.theme.primary.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: _buildRangeInput(
                      controller: _endController,
                      focusNode: _endFocus,
                      label: 'To',
                      hintText: widget.fileCount.toString(),
                      theme: widget.theme,
                    ),
                  ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.theme.secondaryText,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: widget.theme.alternate,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: widget.theme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.theme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Select Range',
                        style: widget.theme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required FlutterFlowTheme theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.labelSmall.copyWith(
            color: theme.secondaryText,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus
                  ? theme.primary
                  : theme.alternate,
              width: focusNode.hasFocus ? 2 : 1.5,
            ),
            boxShadow: focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: theme.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.titleLarge.copyWith(
                color: theme.secondaryText.withValues(alpha: 0.4),
                fontWeight: FontWeight.w300,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}
