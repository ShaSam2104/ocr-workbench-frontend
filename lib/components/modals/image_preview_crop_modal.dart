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

  void _onCropped(Uint8List croppedData) {
    if (_currentCropIndex != null) {
      setState(() {
        _files[_currentCropIndex!].imageBytes = croppedData;
        _files[_currentCropIndex!].hasCropped = true;
        _currentCropIndex = null;
      });
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      _files[index].isSelected = !_files[index].isSelected;
    });
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
                    initialSize: 0.8,
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
                    child: Image.memory(
                      file.imageBytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
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
