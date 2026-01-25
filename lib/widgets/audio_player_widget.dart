import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '/flutter_flow/flutter_flow_theme.dart';

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
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorMessage;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  
  // Stream subscriptions to cancel on dispose
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
    
    // Listen to playback state
    _playbackSubscription = _audioPlayer.playbackEventStream.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = _audioPlayer.playing;
          _position = _audioPlayer.position;
          _duration = _audioPlayer.duration ?? Duration.zero;
        });
      }
    });

    // Listen to player state
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() => _isLoading = true);
      await _audioPlayer.setUrl(widget.audioUrl);
      if (mounted) {
        setState(() {
          _duration = _audioPlayer.duration ?? Duration.zero;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load audio';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Playback error');
      }
    }
  }

  Future<void> _rewind() async {
    final newPosition = _position - const Duration(seconds: 10);
    await _audioPlayer.seek(
      newPosition.isNegative ? Duration.zero : newPosition,
    );
  }

  Future<void> _forward() async {
    final newPosition = _position + const Duration(seconds: 10);
    await _audioPlayer.seek(
      newPosition > _duration ? _duration : newPosition,
    );
  }

  @override
  void dispose() {
    // Cancel stream subscriptions to prevent setState() after dispose
    _playbackSubscription.cancel();
    _playerStateSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: Text(
            _errorMessage!,
            style: theme.bodySmall.copyWith(color: theme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar with time display
          Column(
            children: [
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  final newPosition = Duration(
                    milliseconds: (progress * _duration.inMilliseconds +
                        details.delta.dx * _duration.inMilliseconds / 200)
                        .clamp(0, _duration.inMilliseconds)
                        .toInt(),
                  );
                  _audioPlayer.seek(newPosition);
                },
                child: SizedBox(
                  height: 24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          value: progress,
                          backgroundColor: theme.alternate,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: theme.bodySmall.copyWith(
                      color: theme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: theme.bodySmall.copyWith(
                      color: theme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Control buttons - compact layout
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind button
              InkWell(
                onTap: _isLoading ? null : _rewind,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.replay_10,
                    color: _isLoading ? theme.secondaryText : theme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Play/Pause button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _isLoading
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _togglePlayPause,
                          child: Center(
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              
              // Forward button
              InkWell(
                onTap: _isLoading ? null : _forward,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.forward_10,
                    color: _isLoading ? theme.secondaryText : theme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}