import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

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
  final String path;
  final String fileType; // 'image' or 'audio'
  final int sizeBytes;

  FileItem({
    required this.id,
    required this.name,
    required this.path,
    required this.fileType,
    required this.sizeBytes,
  });
}

class ProcessingItem {
  final String id;
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
        type: fileType == 'image' ? FileType.image : FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            _selectedFiles.add(
              FileItem(
                id: UniqueKey().toString(),
                name: file.name,
                path: file.path ?? '',
                fileType: fileType,
                sizeBytes: file.size,
              ),
            );
          }
        });
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
      // Call API to start OCR processing
      final response =
          await OCRWorkbenchAPIGroup.processImagesOcrCall.call(
        imageIdsList: imageFiles.map((f) => int.tryParse(f.id) ?? 0).toList(),
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
      // Call API to start transcription
      final response =
          await OCRWorkbenchAPIGroup.transcribeAudiosCall.call(
        audioIdsList: audioFiles.map((f) => int.tryParse(f.id) ?? 0).toList(),
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
      taskId: _ocrTaskId,
    );

    if (response.succeeded) {
      final jsonBody = response.jsonBody as Map<String, dynamic>?;
      final results = jsonBody?['results'] as List<dynamic>?;

      if (results != null) {
        setState(() {
          _completedCount = 0;
          _failedCount = 0;

          for (var result in results) {
            final itemId = result['image_id'] as String?;
            final status = result['status'] as String?;
            final errorMsg = result['error'] as String?;

            final itemIndex =
                _processingItems.indexWhere((i) => i.id == itemId);
            if (itemIndex >= 0) {
              _processingItems[itemIndex].status = status ?? 'pending';
              _processingItems[itemIndex].errorMessage = errorMsg;

              if (status == 'completed') {
                _processingItems[itemIndex].progress = 1.0;
                _completedCount++;
              } else if (status == 'failed') {
                _failedCount++;
              } else {
                _processingItems[itemIndex].progress = 0.5;
              }
            }
          }

          // Stop polling if all items are done
          if (_completedCount + _failedCount == _processingItems.length) {
            _isPolling = false;
            _statusPollingTimer?.cancel();
          }
        });
      }
    }
  }

  Future<void> _pollTranscriptionStatus() async {
    final response = await OCRWorkbenchAPIGroup.getTranscriptionStatusCall.call(
      taskId: _transcriptionTaskId,
    );

    if (response.succeeded) {
      final jsonBody = response.jsonBody as Map<String, dynamic>?;
      final results = jsonBody?['results'] as List<dynamic>?;

      if (results != null) {
        setState(() {
          _completedCount = 0;
          _failedCount = 0;

          for (var result in results) {
            final itemId = result['audio_id'] as String?;
            final status = result['status'] as String?;
            final errorMsg = result['error'] as String?;

            final itemIndex =
                _processingItems.indexWhere((i) => i.id == itemId);
            if (itemIndex >= 0) {
              _processingItems[itemIndex].status = status ?? 'pending';
              _processingItems[itemIndex].errorMessage = errorMsg;

              if (status == 'completed') {
                _processingItems[itemIndex].progress = 1.0;
                _completedCount++;
              } else if (status == 'failed') {
                _failedCount++;
              } else {
                _processingItems[itemIndex].progress = 0.5;
              }
            }
          }

          // Stop polling if all items are done
          if (_completedCount + _failedCount == _processingItems.length) {
            _isPolling = false;
            _statusPollingTimer?.cancel();
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
    widget.onUploadComplete?.call();
    Navigator.of(context).pop();
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
                  color: theme.primary.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upload & Process',
                          style: theme.headlineSmall,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.borderColor,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.primary.withValues(alpha: 0.1),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: theme.primary,
                    unselectedLabelColor: theme.secondaryText,
                    indicatorColor: theme.primary,
                    tabs: const [
                      Tab(text: 'Upload'),
                      Tab(text: 'Processing'),
                      Tab(text: 'Results'),
                    ],
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
    );
  }

  Widget _buildUploadTab(BuildContext context, FlutterFlowTheme theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickFiles('image'),
                    icon: const Icon(Icons.image),
                    label: const Text('Select Images'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickFiles('audio'),
                    icon: const Icon(Icons.audio_file),
                    label: const Text('Select Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedFiles.isNotEmpty) ...[
              Text(
                'Selected Files (${_selectedFiles.length})',
                style: theme.labelLarge,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.primary.withValues(alpha: 0.2),
                  ),
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
                    return ListTile(
                      leading: Icon(
                        file.fileType == 'image'
                            ? Icons.image
                            : Icons.audio_file,
                        color: theme.primary,
                      ),
                      title: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${(file.sizeBytes / 1024).toStringAsFixed(1)} KB',
                        style: theme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: theme.error),
                        onPressed: () => _removeFile(file.id),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: theme.borderColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No files selected',
                      style: theme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedFiles
                            .where((f) => f.fileType == 'image')
                            .isNotEmpty
                        ? _startExtraction
                        : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Start Extraction (Ctrl+E)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    icon: const Icon(Icons.transcribe),
                    label: const Text('Start Transcription (Ctrl+T)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
