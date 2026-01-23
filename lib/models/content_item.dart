enum ContentType { image, audio }

class ContentItem {
  final int id;
  final String name;
  int sequence;
  final ContentType type;
  final String? url;
  final String? thumbnailUrl;
  final String? ocrStatus;
  final String? transcriptionStatus;
  final int? durationSeconds;
  final int? sizeBytes;
  final String? ocrText;
  final String? rawOcrText;
  final String? transcript;
  final String? rawTranscript;

  ContentItem({
    required this.id,
    required this.name,
    required this.sequence,
    required this.type,
    this.url,
    this.thumbnailUrl,
    this.ocrStatus = 'pending',
    this.transcriptionStatus = 'pending',
    this.durationSeconds,
    this.sizeBytes,
    this.ocrText,
    this.rawOcrText,
    this.transcript,
    this.rawTranscript,
  });
}