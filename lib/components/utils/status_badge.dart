import 'package:flutter/material.dart';

enum StatusType { completed, processing, pending, failed }

class StatusBadgeWidget extends StatelessWidget {
  /// Status type to display
  final StatusType status;

  /// Size variant: small, medium, or large
  final String size;

  /// Optional custom label (overrides default status text)
  final String? label;

  const StatusBadgeWidget({
    Key? key,
    required this.status,
    this.size = 'medium',
    this.label,
  }) : super(key: key);

  String _getEmoji() {
    switch (status) {
      case StatusType.completed:
        return '✅';
      case StatusType.processing:
        return '⏳';
      case StatusType.pending:
        return '⏸️';
      case StatusType.failed:
        return '❌';
    }
  }

  String _getStatusText() {
    return label ??
        switch (status) {
          StatusType.completed => 'Completed',
          StatusType.processing => 'Processing',
          StatusType.pending => 'Pending',
          StatusType.failed => 'Failed',
        };
  }

  Color _getBackgroundColor() {
    return switch (status) {
      StatusType.completed => const Color(0xFFDFF2D8).withValues(
          alpha: 0.5), // Light green
      StatusType.processing =>
        const Color(0xFFD1ECF1).withValues(alpha: 0.5), // Light blue
      StatusType.pending =>
        const Color(0xFFECEEF1).withValues(alpha: 0.5), // Light grey
      StatusType.failed =>
        const Color(0xFFF2DEDE).withValues(alpha: 0.5), // Light red
    };
  }

  Color _getTextColor() {
    return switch (status) {
      StatusType.completed => const Color(0xFF3C763D), // Dark green
      StatusType.processing => const Color(0xFF31708F), // Dark blue
      StatusType.pending => const Color(0xFF666666), // Dark grey
      StatusType.failed => const Color(0xFF8B3A3A), // Dark red
    };
  }

  double _getEmojiFontSize() {
    return switch (size) {
      'small' => 12,
      'large' => 24,
      _ => 16, // medium
    };
  }

  double _getTextFontSize() {
    return switch (size) {
      'small' => 11,
      'large' => 15,
      _ => 12, // medium
    };
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      'small' => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      'large' => const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      _ => const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // medium
    };
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: _getPadding(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getEmoji(),
            style: TextStyle(
              fontSize: _getEmojiFontSize(),
            ),
          ),
          if (size != 'small') ...[const SizedBox(width: 4)],
          Text(
            _getStatusText(),
            style: TextStyle(
              color: textColor,
              fontSize: _getTextFontSize(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
