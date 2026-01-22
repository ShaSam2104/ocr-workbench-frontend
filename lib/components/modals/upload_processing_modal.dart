import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocr_workbench/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/uploaded_file.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/modals/image_preview_crop_modal.dart';
import '/utils/pdf_processor.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:typed_data';

class UploadProcessingModal extends StatefulWidget {
  const UploadProcessingModal({
    super.key,
    required this.chapterId,
    this.onClose,
    this.onUploadComplete,
  });

  final String chapterId;
  final VoidCallback? onClose;
  final VoidCallback? onUploadComplete;

  @override
  State<UploadProcessingModal> createState() => _UploadProcessingModalState();
}

enum ProcessingType { ocr, transcription, idle }

class FileItem {
  final String id;
  final String name;
  final String? path;
  final String fileType; // 'image' or 'audio'
  final int sizeBytes;
  final Uint8List? bytes;

  FileItem({
    required this.id,
    required this.name,
    this.path,
    required this.fileType,
    required this.sizeBytes,
    this.bytes,
  });
}

class ProcessingItem {
  String id; // Made non-final so it can be updated with real uploaded ID
  final String name;
  String status; // 'pending', 'processing', 'completed', 'failed'
  double progress;
  String? errorMessage;

  ProcessingItem({
    required this.id,
    required this.name,
    this.status = 'pending',
    this.progress = 0.0,
    this.errorMessage,
  });
}

class _UploadProcessingModalState extends State<UploadProcessingModal>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  List<FileItem> _selectedFiles = [];
  List<ProcessingItem> _processingItems = [];
  ProcessingType _processingType = ProcessingType.idle;
  String? _ocrTaskId;
  String? _transcriptionTaskId;
  Timer? _statusPollingTimer;
  bool _isPolling = false;
  int _completedCount = 0;
  int _failedCount = 0;
  late TabController _tabController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _statusPollingTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      Navigator.of(context).pop();
    } else if (event.isKeyPressed(LogicalKeyboardKey.keyE) &&
        HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.controlLeft)) {
      if (_currentTabIndex == 0) {
        _startExtraction();
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.keyT) &&
        HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.controlLeft)) {
      if (_currentTabIndex == 0) {
        _startTranscription();
      }
    }
  }

  Future<void> _pickFiles(String fileType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType == 'image'
            ? FileType.custom
            : FileType.audio,
        allowMultiple: true,
        allowedExtensions: fileType == 'image'
            ? ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf']
            : null,
      );

      if (result != null) {
        // Process files and extract images from PDFs if needed
        final List<FileForPreview> previewFiles = [];
        
        for (var file in result.files) {
          try {
            if (fileType == 'image' && file.name.toLowerCase().endsWith('.pdf')) {
              // Extract images from PDF
              // Prefer bytes for web/cross-platform, fall back to path for mobile
              final extractedImages = await PDFProcessor.extractImagesFromPDF(
                file.bytes != null ? null : file.path,
                pdfBytes: file.bytes,
              );
              
              for (int i = 0; i < extractedImages.length; i++) {
                previewFiles.add(
                  FileForPreview(
                    id: UniqueKey().toString(),
                    name: '${file.name} - Page ${i + 1}',
                    imageBytes: extractedImages[i],
                    originalFileName: file.name,
                  ),
                );
              }
            } else {
              // Regular image or audio file
              previewFiles.add(
                FileForPreview(
                  id: UniqueKey().toString(),
                  name: file.name,
                  imageBytes: file.bytes ?? Uint8List(0),
                  originalFileName: file.name,
                ),
              );
            }
          } catch (e) {
            _showErrorToast('Error processing ${file.name}: $e');
          }
        }

        if (previewFiles.isNotEmpty && fileType == 'image') {
          // Show preview and crop modal for images
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ImagePreviewCropModal(
              initialFiles: previewFiles,
              onClose: () => Navigator.pop(context),
              onConfirm: (selectedFiles) {
                // Convert selected files back to FileItem format
                setState(() {
                  for (var file in selectedFiles) {
                    _selectedFiles.add(
                      FileItem(
                        id: file.id,
                        name: file.name,
                        fileType: 'image',
                        sizeBytes: file.imageBytes.length,
                        bytes: file.imageBytes,
                      ),
                    );
                  }
                });
              },
            ),
          );
        } else if (previewFiles.isNotEmpty) {
          // For audio, directly add to selected files
          setState(() {
            for (var file in previewFiles) {
              _selectedFiles.add(
                FileItem(
                  id: file.id,
                  name: file.name,
                  fileType: fileType,
                  sizeBytes: file.imageBytes.length,
                  bytes: file.imageBytes,
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      _showErrorToast('Error picking files: $e');
    }
  }

  void _removeFile(String fileId) {
    setState(() {
      _selectedFiles.removeWhere((f) => f.id == fileId);
    });
  }

  Future<void> _startExtraction() async {
    if (_selectedFiles.isEmpty) {
      _showErrorToast('Please select files first');
      return;
    }

    final imageFiles =
        _selectedFiles.where((f) => f.fileType == 'image').toList();
    if (imageFiles.isEmpty) {
      _showErrorToast('Please select at least one image file');
      return;
    }

    // Initialize processing items
    setState(() {
      _processingItems = imageFiles
          .map((f) => ProcessingItem(id: f.id, name: f.name))
          .toList();
      _processingType = ProcessingType.ocr;
      _completedCount = 0;
      _failedCount = 0;
      _isPolling = true;
    });

    // Move to processing tab
    _tabController.animateTo(1);

    try {
      // Prepare files for upload with correct MIME types
      final List<FFUploadedFile> filesToUpload = [];
      
      for (final f in imageFiles) {
        if (f.bytes != null) {
          final mimeType = _detectImageMimeType(f.bytes!, f.name);
          filesToUpload.add(FFUploadedFile(
            name: f.name,
            bytes: f.bytes,
            mimeType: mimeType,
          ));
        }
      }

      if (filesToUpload.isEmpty) {
        _showErrorToast('No valid image files to upload');
        setState(() {
          _isPolling = false;
        });
        return;
      }

      // Upload all images at once
      final uploadResponse = await OCRWorkbenchAPIGroup.uploadImagesCall.call(
        chapterId: int.tryParse(widget.chapterId),
        filesList: filesToUpload,
        hTTPBearer: authManager.authenticationToken,
      );

      if (!uploadResponse.succeeded) {
        _showErrorToast('Failed to upload images');
        setState(() {
          _isPolling = false;
        });
        return;
      }

      // Extract image IDs from the response and create mapping
      final jsonBody = uploadResponse.jsonBody;
      final List<int> uploadedImageIds = [];
      final Map<String, int> tempIdToRealId = {}; // temp FileItem.id -> real image ID
      
      if (jsonBody is List) {
        for (int i = 0; i < jsonBody.length; i++) {
          final item = jsonBody[i];
          final imageId = item['id'] as int?;
          if (imageId != null && i < imageFiles.length) {
            uploadedImageIds.add(imageId);
            tempIdToRealId[imageFiles[i].id] = imageId;
          }
        }
      }

      if (uploadedImageIds.isEmpty) {
        _showErrorToast('No images were uploaded successfully');
        setState(() {
          _isPolling = false;
        });
        return;
      }

      // Update processing items with real IDs
      setState(() {
        for (var item in _processingItems) {
          final realId = tempIdToRealId[item.id];
          if (realId != null) {
            item.id = realId.toString();
          }
        }
      });

      // Call API to start OCR processing with the uploaded image IDs
      final response =
          await OCRWorkbenchAPIGroup.processImagesOcrCall.call(
        imageIdsList: uploadedImageIds,
        hTTPBearer: authManager.authenticationToken,
      );

      if (response.succeeded) {
        final jsonBody = response.jsonBody as Map<String, dynamic>?;
        final taskId = jsonBody?['task_id'] as String?;

        if (taskId != null) {
          setState(() {
            _ocrTaskId = taskId; 
          });

          // Start polling for status
          _startStatusPolling(ProcessingType.ocr);
        } else {
          _showErrorToast('No task ID received from server');
        }
      } else {
        _showErrorToast('Failed to start OCR processing');
      }
    } catch (e) {
      _showErrorToast('Error starting extraction: $e');
      setState(() {
        _isPolling = false;
      });
    }
  }

  // Helper function to detect image MIME type from magic bytes
  String _detectImageMimeType(Uint8List bytes, String fileName) {
    if (bytes.length < 4) {
      // Fall back to file extension
      return _mimeTypeFromExtension(fileName);
    }

    // Check magic bytes
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return 'image/png';
    }
    
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    
    // GIF: 47 49 46 38 (GIF8)
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return 'image/gif';
    }
    
    // WebP: RIFF ... WEBP
    if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
      if (bytes.length >= 12 &&
          bytes[8] == 0x57 && bytes[9] == 0x45 && 
          bytes[10] == 0x42 && bytes[11] == 0x50) {
        return 'image/webp';
      }
    }
    
    // BMP: 42 4D
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return 'image/bmp';
    }

    // Fall back to file extension
    return _mimeTypeFromExtension(fileName);
  }

  // Helper to get MIME type from file extension
  String _mimeTypeFromExtension(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg'; // Default to JPEG for PDF-extracted images
    }
  }

  Future<void> _startTranscription() async {
    if (_selectedFiles.isEmpty) {
      _showErrorToast('Please select files first');
      return;
    }

    final audioFiles =
        _selectedFiles.where((f) => f.fileType == 'audio').toList();
    if (audioFiles.isEmpty) {
      _showErrorToast('Please select at least one audio file');
      return;
    }

    // Initialize processing items
    setState(() {
      _processingItems = audioFiles
          .map((f) => ProcessingItem(id: f.id, name: f.name))
          .toList();
      _processingType = ProcessingType.transcription;
      _completedCount = 0;
      _failedCount = 0;
      _isPolling = true;
    });

    // Move to processing tab
    _tabController.animateTo(1);

    try {
      // First, upload the audio files to get real audio IDs
      final List<FFUploadedFile> filesToUpload = audioFiles
          .where((f) => f.bytes != null)
          .map((f) => FFUploadedFile(
                name: f.name,
                bytes: f.bytes,
              ))
          .toList();

      if (filesToUpload.isEmpty) {
        _showErrorToast('No valid audio files to upload');
        setState(() {
          _isPolling = false;
        });
        return;
      }

      // Upload all audio files at once
      final uploadResponse = await OCRWorkbenchAPIGroup.uploadAudiosCall.call(
        chapterId: int.tryParse(widget.chapterId),
        filesList: filesToUpload,
        hTTPBearer: authManager.authenticationToken,
      );

      if (!uploadResponse.succeeded) {
        _showErrorToast('Failed to upload audio files');
        setState(() {
          _isPolling = false;
        });
        return;
      }

      // Extract audio IDs from the response and create mapping
      final jsonBody = uploadResponse.jsonBody;
      final List<int> uploadedAudioIds = [];
      final Map<String, int> tempIdToRealId = {}; // temp FileItem.id -> real audio ID
      
      if (jsonBody is List) {
        for (int i = 0; i < jsonBody.length; i++) {
          final item = jsonBody[i];
          final audioId = item['id'] as int?;
          if (audioId != null && i < audioFiles.length) {
            uploadedAudioIds.add(audioId);
            tempIdToRealId[audioFiles[i].id] = audioId;
          }
        }
      }

      if (uploadedAudioIds.isEmpty) {
        _showErrorToast('No audio files were uploaded successfully');
        setState(() {
          _isPolling = false;
        });
        return;
      }

      // Update processing items with real IDs - batch update
      setState(() {
        for (var item in _processingItems) {
          final realId = tempIdToRealId[item.id];
          if (realId != null) {
            item.id = realId.toString();
          }
        }
      });

      // Call API to start transcription with the uploaded audio IDs
      final response =
          await OCRWorkbenchAPIGroup.transcribeAudiosCall.call(
        audioIdsList: uploadedAudioIds,
        hTTPBearer: authManager.authenticationToken,
      );

      if (response.succeeded) {
        final jsonBody = response.jsonBody as Map<String, dynamic>?;
        final taskId = jsonBody?['task_id'] as String?;

        if (taskId != null) {
          setState(() {
            _transcriptionTaskId = taskId;
          });

          // Start polling for status
          _startStatusPolling(ProcessingType.transcription);
        } else {
          _showErrorToast('No task ID received from server');
        }
      } else {
        _showErrorToast('Failed to start transcription');
      }
    } catch (e) {
      _showErrorToast('Error starting transcription: $e');
      setState(() {
        _isPolling = false;
      });
    }
  }

  void _startStatusPolling(ProcessingType type) {
    _statusPollingTimer?.cancel();

    _statusPollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) async {
        if (!_isPolling) return;

        try {
          if (type == ProcessingType.ocr && _ocrTaskId != null) {
            await _pollOcrStatus();
          } else if (type == ProcessingType.transcription &&
              _transcriptionTaskId != null) {
            await _pollTranscriptionStatus();
          }
        } catch (e) {
          debugPrint('Polling error: $e');
        }
      },
    );
  }

  Future<void> _pollOcrStatus() async {
    final response = await OCRWorkbenchAPIGroup.getOcrStatusCall.call(
      hTTPBearer: authManager.authenticationToken,
      taskId: _ocrTaskId,
    );

    if (response.succeeded) {
      final jsonBody = response.jsonBody as Map<String, dynamic>?;
      
      // Check top-level task status first
      final taskStatus = jsonBody?['status'] as String?;
      final images = jsonBody?['images'] as List<dynamic>?;

      if (images != null) {
        // Batch state update instead of per-item updates
        int newCompletedCount = 0;
        int newFailedCount = 0;
        
        for (var image in images) {
          final imageId = image['image_id'] as int?;
          final status = image['status'] as String?;
          final errorMsg = image['error'] as String?;

          // Match by image ID
          final itemIndex = _processingItems.indexWhere(
            (i) => i.id == imageId.toString()
          );
          
          if (itemIndex >= 0) {
            _processingItems[itemIndex].status = status ?? 'pending';
            _processingItems[itemIndex].errorMessage = errorMsg;

            if (status == 'completed') {
              _processingItems[itemIndex].progress = 1.0;
              newCompletedCount++;
            } else if (status == 'failed') {
              newFailedCount++;
            } else if (status == 'processing') {
              _processingItems[itemIndex].progress = 0.5;
            }
          }
        }

        setState(() {
          _completedCount = newCompletedCount;
          _failedCount = newFailedCount;
          
          // Stop polling if task is completed or all items are done
          if (taskStatus == 'completed' || 
              taskStatus == 'failed' ||
              _completedCount + _failedCount == _processingItems.length) {
            _isPolling = false;
            _statusPollingTimer?.cancel();
            
            // Auto-dismiss modal and trigger refresh when complete
            if (taskStatus == 'completed' && _completedCount > 0) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _viewResults();
                }
              });
            }
          }
        });
      }
    }
  }

  Future<void> _pollTranscriptionStatus() async {
    final response = await OCRWorkbenchAPIGroup.getTranscriptionStatusCall.call(
      taskId: _transcriptionTaskId,
      hTTPBearer: authManager.authenticationToken,
    );

    if (response.succeeded) {
      final jsonBody = response.jsonBody as Map<String, dynamic>?;
      
      // Check top-level task status first
      final taskStatus = jsonBody?['status'] as String?;
      final audios = jsonBody?['audios'] as List<dynamic>?;

      if (audios != null) {
        // Batch state update instead of per-item updates
        int newCompletedCount = 0;
        int newFailedCount = 0;
        
        for (var audio in audios) {
          final audioId = audio['audio_id'] as int?;
          final status = audio['status'] as String?;
          final errorMsg = audio['error'] as String?;

          // Match by audio ID
          final itemIndex = _processingItems.indexWhere(
            (i) => i.id == audioId.toString()
          );
          
          if (itemIndex >= 0) {
            _processingItems[itemIndex].status = status ?? 'pending';
            _processingItems[itemIndex].errorMessage = errorMsg;

            if (status == 'completed') {
              _processingItems[itemIndex].progress = 1.0;
              newCompletedCount++;
            } else if (status == 'failed') {
              newFailedCount++;
            } else if (status == 'processing') {
              _processingItems[itemIndex].progress = 0.5;
            }
          }
        }

        setState(() {
          _completedCount = newCompletedCount;
          _failedCount = newFailedCount;
          
          // Stop polling if task is completed or all items are done
          if (taskStatus == 'completed' || 
              taskStatus == 'failed' ||
              _completedCount + _failedCount == _processingItems.length) {
            _isPolling = false;
            _statusPollingTimer?.cancel();
            
            // Auto-dismiss modal and trigger refresh when complete
            if (taskStatus == 'completed' && _completedCount > 0) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _viewResults();
                }
              });
            }
          }
        });
      }
    }
  }

  void _cancelProcessing() {
    setState(() {
      _isPolling = false;
      _statusPollingTimer?.cancel();
      _ocrTaskId = null;
      _transcriptionTaskId = null;
      _processingType = ProcessingType.idle;
    });
  }

  void _viewResults() {
    // Trigger refresh callback before dismissing
    widget.onUploadComplete?.call();
    // Dismiss the modal safely
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            decoration: const BoxDecoration(
              color: Color(0xB31E1E1F),
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {},
              child: Container(
                width: isDesktop
                    ? 800.0
                    : isTablet
                        ? MediaQuery.sizeOf(context).width * 0.9
                        : MediaQuery.sizeOf(context).width * 0.95,
                constraints: const BoxConstraints(maxHeight: 700),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: theme.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.upload_file_rounded,
                                color: theme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Upload & Process',
                              style: theme.headlineSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.secondaryText,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: theme.primary,
                      unselectedLabelColor: theme.secondaryText,
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorColor: theme.primary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.upload_rounded, size: 20),
                          text: 'Upload',
                          height: 60,
                        ),
                        Tab(
                          icon: Icon(Icons.pending_actions_rounded, size: 20),
                          text: 'Processing',
                          height: 60,
                        ),
                        Tab(
                          icon: Icon(Icons.task_alt_rounded, size: 20),
                          text: 'Results',
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUploadTab(context, theme),
                        _buildProcessingTab(context, theme),
                        _buildResultsTab(context, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildUploadTab(BuildContext context, FlutterFlowTheme theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickFiles('image'),
                    icon: const Icon(Icons.photo_library_rounded, size: 20),
                    label: const Text('Select Images', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickFiles('audio'),
                    icon: const Icon(Icons.audiotrack_rounded, size: 20),
                    label: const Text('Select Audio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondary,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (_selectedFiles.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: theme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'File' : 'Files'} Selected',
                          style: theme.labelMedium.copyWith(
                            color: theme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primary.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _selectedFiles.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: theme.primary.withValues(alpha: 0.1),
                  ),
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (file.fileType == 'image' ? theme.primary : theme.secondary).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            file.fileType == 'image'
                                ? Icons.photo_library_rounded
                                : Icons.audiotrack_rounded,
                            color: file.fileType == 'image' ? theme.primary : theme.secondary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${(file.sizeBytes / 1024).toStringAsFixed(1)} KB',
                          style: theme.bodySmall.copyWith(
                            color: theme.secondaryText,
                          ),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: theme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.close_rounded, color: theme.error, size: 20),
                            onPressed: () => _removeFile(file.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.primaryBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primary.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      size: 48,
                      color: theme.secondaryText.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No files selected yet',
                      style: theme.headlineSmall.copyWith(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose images or audio files to get started',
                      style: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedFiles
                            .where((f) => f.fileType == 'image')
                            .isNotEmpty
                        ? _startExtraction
                        : null,
                    icon: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Start Extraction (Ctrl+E)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: theme.primaryBackground.withValues(alpha: 0.5),
                      disabledForegroundColor: theme.secondaryText.withValues(alpha: 0.5),
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedFiles
                            .where((f) => f.fileType == 'audio')
                            .isNotEmpty
                        ? _startTranscription
                        : null,
                    icon: const Icon(
                      Icons.graphic_eq_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Start Transcription (Ctrl+T)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: theme.primaryBackground.withValues(alpha: 0.5),
                      disabledForegroundColor: theme.secondaryText.withValues(alpha: 0.5),
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingTab(BuildContext context, FlutterFlowTheme theme) {
    if (_processingItems.isEmpty) {
      return Center(
        child: Text(
          'No processing in progress',
          style: theme.bodyLarge,
        ),
      );
    }

    final int totalItems = _processingItems.length;
    final double overallProgress = totalItems > 0
        ? (_completedCount + _failedCount) / totalItems
        : 0.0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_processingType == ProcessingType.ocr ? 'OCR Extraction' : 'Transcription'} Progress',
                  style: theme.labelLarge,
                ),
                Text(
                  '${(overallProgress * 100).toStringAsFixed(0)}%',
                  style: theme.labelMedium.copyWith(
                    color: theme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: overallProgress,
                minHeight: 8,
                backgroundColor: theme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(theme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.2),
                ),
              ),
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _processingItems.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: theme.primary.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final item = _processingItems[index];
                  return ListTile(
                    leading: _buildStatusIcon(item.status, theme),
                    title: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            minHeight: 4,
                            backgroundColor:
                                theme.primary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(
                              item.status == 'failed'
                                  ? theme.error
                                  : theme.primary,
                            ),
                          ),
                        ),
                        if (item.errorMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.errorMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall.copyWith(
                              color: theme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusChip(
                    '${_processingItems.where((i) => i.status == 'pending').length}',
                    'Pending',
                    Colors.grey,
                  ),
                  _buildStatusChip(
                    '${_processingItems.where((i) => i.status == 'processing').length}',
                    'Processing',
                    Colors.orange,
                  ),
                  _buildStatusChip(
                    '$_completedCount',
                    'Completed',
                    Colors.green,
                  ),
                  _buildStatusChip(
                    '$_failedCount',
                    'Failed',
                    Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cancelProcessing,
                icon: const Icon(Icons.stop_circle),
                label: const Text('Cancel Processing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTab(BuildContext context, FlutterFlowTheme theme) {
    final isComplete = !_isPolling && _processingItems.isNotEmpty;
    final isSuccess = _failedCount == 0 && _completedCount > 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              size: 64,
              color: isSuccess ? Colors.green : theme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isComplete
                  ? isSuccess
                      ? 'Processing Complete!'
                      : 'Processing Finished with Errors'
                  : 'Processing in Progress',
              style: theme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (isComplete) ...[
              Text(
                '$_completedCount items completed${_failedCount > 0 ? ', $_failedCount failed' : ''}',
                style: theme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _viewResults,
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(theme.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please wait while processing continues in the background',
                style: theme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status, FlutterFlowTheme theme) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.schedule, color: Colors.grey, size: 24);
      case 'processing':
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.orange),
          ),
        );
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
      case 'failed':
        return const Icon(Icons.error, color: Colors.red, size: 24);
      default:
        return Icon(Icons.help, color: theme.borderColor, size: 24);
    }
  }

  Widget _buildStatusChip(String count, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
