// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PostAudioResponseStruct extends BaseStruct {
  PostAudioResponseStruct({
    int? id,
    int? chapterId,
    String? objectKey,
    String? filename,
    int? sequenceNumber,
    int? durationSeconds,
    String? audioFormat,
    int? fileSize,
    String? detectedLanguage,
    String? transcriptionStatus,
    String? createdAt,
    String? updatedAt,
  })  : _id = id,
        _chapterId = chapterId,
        _objectKey = objectKey,
        _filename = filename,
        _sequenceNumber = sequenceNumber,
        _durationSeconds = durationSeconds,
        _audioFormat = audioFormat,
        _fileSize = fileSize,
        _detectedLanguage = detectedLanguage,
        _transcriptionStatus = transcriptionStatus,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "chapter_id" field.
  int? _chapterId;
  int get chapterId => _chapterId ?? 0;
  set chapterId(int? val) => _chapterId = val;

  void incrementChapterId(int amount) => chapterId = chapterId + amount;

  bool hasChapterId() => _chapterId != null;

  // "object_key" field.
  String? _objectKey;
  String get objectKey => _objectKey ?? '';
  set objectKey(String? val) => _objectKey = val;

  bool hasObjectKey() => _objectKey != null;

  // "filename" field.
  String? _filename;
  String get filename => _filename ?? '';
  set filename(String? val) => _filename = val;

  bool hasFilename() => _filename != null;

  // "sequence_number" field.
  int? _sequenceNumber;
  int get sequenceNumber => _sequenceNumber ?? 0;
  set sequenceNumber(int? val) => _sequenceNumber = val;

  void incrementSequenceNumber(int amount) =>
      sequenceNumber = sequenceNumber + amount;

  bool hasSequenceNumber() => _sequenceNumber != null;

  // "duration_seconds" field.
  int? _durationSeconds;
  int get durationSeconds => _durationSeconds ?? 0;
  set durationSeconds(int? val) => _durationSeconds = val;

  void incrementDurationSeconds(int amount) =>
      durationSeconds = durationSeconds + amount;

  bool hasDurationSeconds() => _durationSeconds != null;

  // "audio_format" field.
  String? _audioFormat;
  String get audioFormat => _audioFormat ?? '';
  set audioFormat(String? val) => _audioFormat = val;

  bool hasAudioFormat() => _audioFormat != null;

  // "file_size" field.
  int? _fileSize;
  int get fileSize => _fileSize ?? 0;
  set fileSize(int? val) => _fileSize = val;

  void incrementFileSize(int amount) => fileSize = fileSize + amount;

  bool hasFileSize() => _fileSize != null;

  // "detected_language" field.
  String? _detectedLanguage;
  String get detectedLanguage => _detectedLanguage ?? '';
  set detectedLanguage(String? val) => _detectedLanguage = val;

  bool hasDetectedLanguage() => _detectedLanguage != null;

  // "transcription_status" field.
  String? _transcriptionStatus;
  String get transcriptionStatus => _transcriptionStatus ?? '';
  set transcriptionStatus(String? val) => _transcriptionStatus = val;

  bool hasTranscriptionStatus() => _transcriptionStatus != null;

  // "created_at" field.
  String? _createdAt;
  String get createdAt => _createdAt ?? '';
  set createdAt(String? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field.
  String? _updatedAt;
  String get updatedAt => _updatedAt ?? '';
  set updatedAt(String? val) => _updatedAt = val;

  bool hasUpdatedAt() => _updatedAt != null;

  static PostAudioResponseStruct fromMap(Map<String, dynamic> data) =>
      PostAudioResponseStruct(
        id: castToType<int>(data['id']),
        chapterId: castToType<int>(data['chapter_id']),
        objectKey: data['object_key'] as String?,
        filename: data['filename'] as String?,
        sequenceNumber: castToType<int>(data['sequence_number']),
        durationSeconds: castToType<int>(data['duration_seconds']),
        audioFormat: data['audio_format'] as String?,
        fileSize: castToType<int>(data['file_size']),
        detectedLanguage: data['detected_language'] as String?,
        transcriptionStatus: data['transcription_status'] as String?,
        createdAt: data['created_at'] as String?,
        updatedAt: data['updated_at'] as String?,
      );

  static PostAudioResponseStruct? maybeFromMap(dynamic data) => data is Map
      ? PostAudioResponseStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'chapter_id': _chapterId,
        'object_key': _objectKey,
        'filename': _filename,
        'sequence_number': _sequenceNumber,
        'duration_seconds': _durationSeconds,
        'audio_format': _audioFormat,
        'file_size': _fileSize,
        'detected_language': _detectedLanguage,
        'transcription_status': _transcriptionStatus,
        'created_at': _createdAt,
        'updated_at': _updatedAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'chapter_id': serializeParam(
          _chapterId,
          ParamType.int,
        ),
        'object_key': serializeParam(
          _objectKey,
          ParamType.String,
        ),
        'filename': serializeParam(
          _filename,
          ParamType.String,
        ),
        'sequence_number': serializeParam(
          _sequenceNumber,
          ParamType.int,
        ),
        'duration_seconds': serializeParam(
          _durationSeconds,
          ParamType.int,
        ),
        'audio_format': serializeParam(
          _audioFormat,
          ParamType.String,
        ),
        'file_size': serializeParam(
          _fileSize,
          ParamType.int,
        ),
        'detected_language': serializeParam(
          _detectedLanguage,
          ParamType.String,
        ),
        'transcription_status': serializeParam(
          _transcriptionStatus,
          ParamType.String,
        ),
        'created_at': serializeParam(
          _createdAt,
          ParamType.String,
        ),
        'updated_at': serializeParam(
          _updatedAt,
          ParamType.String,
        ),
      }.withoutNulls;

  static PostAudioResponseStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      PostAudioResponseStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        chapterId: deserializeParam(
          data['chapter_id'],
          ParamType.int,
          false,
        ),
        objectKey: deserializeParam(
          data['object_key'],
          ParamType.String,
          false,
        ),
        filename: deserializeParam(
          data['filename'],
          ParamType.String,
          false,
        ),
        sequenceNumber: deserializeParam(
          data['sequence_number'],
          ParamType.int,
          false,
        ),
        durationSeconds: deserializeParam(
          data['duration_seconds'],
          ParamType.int,
          false,
        ),
        audioFormat: deserializeParam(
          data['audio_format'],
          ParamType.String,
          false,
        ),
        fileSize: deserializeParam(
          data['file_size'],
          ParamType.int,
          false,
        ),
        detectedLanguage: deserializeParam(
          data['detected_language'],
          ParamType.String,
          false,
        ),
        transcriptionStatus: deserializeParam(
          data['transcription_status'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['created_at'],
          ParamType.String,
          false,
        ),
        updatedAt: deserializeParam(
          data['updated_at'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'PostAudioResponseStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PostAudioResponseStruct &&
        id == other.id &&
        chapterId == other.chapterId &&
        objectKey == other.objectKey &&
        filename == other.filename &&
        sequenceNumber == other.sequenceNumber &&
        durationSeconds == other.durationSeconds &&
        audioFormat == other.audioFormat &&
        fileSize == other.fileSize &&
        detectedLanguage == other.detectedLanguage &&
        transcriptionStatus == other.transcriptionStatus &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        chapterId,
        objectKey,
        filename,
        sequenceNumber,
        durationSeconds,
        audioFormat,
        fileSize,
        detectedLanguage,
        transcriptionStatus,
        createdAt,
        updatedAt
      ]);
}

PostAudioResponseStruct createPostAudioResponseStruct({
  int? id,
  int? chapterId,
  String? objectKey,
  String? filename,
  int? sequenceNumber,
  int? durationSeconds,
  String? audioFormat,
  int? fileSize,
  String? detectedLanguage,
  String? transcriptionStatus,
  String? createdAt,
  String? updatedAt,
}) =>
    PostAudioResponseStruct(
      id: id,
      chapterId: chapterId,
      objectKey: objectKey,
      filename: filename,
      sequenceNumber: sequenceNumber,
      durationSeconds: durationSeconds,
      audioFormat: audioFormat,
      fileSize: fileSize,
      detectedLanguage: detectedLanguage,
      transcriptionStatus: transcriptionStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
