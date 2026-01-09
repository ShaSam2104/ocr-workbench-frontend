import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ProgressOverlayWidget extends StatelessWidget {
  /// Number of completed items
  final int completedCount;

  /// Total number of items
  final int totalCount;

  /// Label describing the progress (e.g., "Images processed")
  final String label;

  /// Type of progress display: 'linear' or 'circular'
  final String progressType;

  /// Optional cancel button callback
  final VoidCallback? onCancel;

  /// Keyboard shortcut hint for cancel button
  final String? cancelKeyboardShortcut;

  const ProgressOverlayWidget({
    Key? key,
    required this.completedCount,
    required this.totalCount,
    this.label = 'Processing',
    this.progressType = 'linear',
    this.onCancel,
    this.cancelKeyboardShortcut,
  }) : super(key: key);

  double _getProgress() {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }

  int _getPercentage() {
    return (_getProgress() * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final progress = _getProgress();
    final percentage = _getPercentage();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            label,
            style: theme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Progress display based on type
          if (progressType == 'circular')
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primary,
                    ),
                    backgroundColor: theme.alternate.withValues(alpha: 0.3),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: theme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                      ),
                    ),
                    Text(
                      '$completedCount/$totalCount',
                      style: theme.bodySmall.copyWith(
                        color: theme.secondaryText.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Linear progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: theme.alternate.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Progress text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedCount/$totalCount done',
                      style: theme.bodySmall.copyWith(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: theme.bodySmall.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Cancel button
          if (onCancel != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.error,
                  side: BorderSide(
                    color: theme.error,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cancel',
                      style: theme.bodyMedium.copyWith(
                        color: theme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (cancelKeyboardShortcut != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '($cancelKeyboardShortcut)',
                          style: theme.bodySmall.copyWith(
                            color: theme.error.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
