import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class OcrProcessingResult {
  final String customPrompt;
  final String model;
  OcrProcessingResult({required this.customPrompt, required this.model});
}

class OcrProcessingModal extends StatefulWidget {
  const OcrProcessingModal({super.key});

  @override
  State<OcrProcessingModal> createState() => _OcrProcessingModalState();
}

class _OcrProcessingModalState extends State<OcrProcessingModal> {
  late TextEditingController _customPromptController;
  String _selectedModel = 'lower'; // Default to lower model

  @override
  void initState() {
    super.initState();
    _customPromptController = TextEditingController();
  }

  @override
  void dispose() {
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'OCR Processing Settings',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 20.0),

              // Model Selection
              Text(
                'Model Type',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    _buildModelRadio('lower', 'Lower Model (Faster)'),
                    Divider(
                      height: 1,
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                    _buildModelRadio('higher', 'Higher Model (More Accurate)'),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Custom Prompt
              Text(
                'Custom Prompt (Optional)',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _customPromptController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter any additional instructions for OCR processing...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).primaryBackground,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 24.0),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, OcrProcessingResult(
                        customPrompt: _customPromptController.text,
                        model: _selectedModel,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Process OCR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelRadio(String value, String label) {
    return InkWell(
      onTap: () => setState(() => _selectedModel = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedModel,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedModel = newValue);
                }
              },
              activeColor: FlutterFlowTheme.of(context).primary,
            ),
            Expanded(
              child: Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
