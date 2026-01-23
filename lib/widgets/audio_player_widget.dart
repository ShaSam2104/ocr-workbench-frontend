import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/painters/waveform_painter.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CustomPaint(
            painter: WaveformPainter(
              color: FlutterFlowTheme.of(context).primary,
            ),
            size: Size(300, 60),
          ),
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() => _isPlaying = !_isPlaying);
                // TODO: Implement actual audio playback
              },
            ),
          ],
        ),
      ],
    );
  }
}