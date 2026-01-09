// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PostImageResponseStruct extends BaseStruct {
  PostImageResponseStruct({
    int? id,
    int? chapterId,
    String? objectKey,
    String? filename,
    int? sequenceNumber,
    String? pageNumber,
    int? fileSize,
    String? fileHash,
    String? detectedLanguage,
    String? ocrStatus,
    bool? isCropped,
    String? createdAt,
    String? updatedAt,
  })  : _id = id,
        _chapterId = chapterId,
        _objectKey = objectKey,
        _filename = filename,
        _sequenceNumber = sequenceNumber,
        _pageNumber = pageNumber,
        _fileSize = fileSize,
        _fileHash = fileHash,
        _detectedLanguage = detectedLanguage,
        _ocrStatus = ocrStatus,
        _isCropped = isCropped,
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

  // "page_number" field.
  String? _pageNumber;
  String get pageNumber => _pageNumber ?? '';
  set pageNumber(String? val) => _pageNumber = val;

  bool hasPageNumber() => _pageNumber != null;

  // "file_size" field.
  int? _fileSize;
  int get fileSize => _fileSize ?? 0;
  set fileSize(int? val) => _fileSize = val;

  void incrementFileSize(int amount) => fileSize = fileSize + amount;

  bool hasFileSize() => _fileSize != null;

  // "file_hash" field.
  String? _fileHash;
  String get fileHash => _fileHash ?? '';
  set fileHash(String? val) => _fileHash = val;

  bool hasFileHash() => _fileHash != null;

  // "detected_language" field.
  String? _detectedLanguage;
  String get detectedLanguage => _detectedLanguage ?? '';
  set detectedLanguage(String? val) => _detectedLanguage = val;

  bool hasDetectedLanguage() => _detectedLanguage != null;

  // "ocr_status" field.
  String? _ocrStatus;
  String get ocrStatus => _ocrStatus ?? '';
  set ocrStatus(String? val) => _ocrStatus = val;

  bool hasOcrStatus() => _ocrStatus != null;

  // "is_cropped" field.
  bool? _isCropped;
  bool get isCropped => _isCropped ?? false;
  set isCropped(bool? val) => _isCropped = val;

  bool hasIsCropped() => _isCropped != null;

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

  static PostImageResponseStruct fromMap(Map<String, dynamic> data) =>
      PostImageResponseStruct(
        id: castToType<int>(data['id']),
        chapterId: castToType<int>(data['chapter_id']),
        objectKey: data['object_key'] as String?,
        filename: data['filename'] as String?,
        sequenceNumber: castToType<int>(data['sequence_number']),
        pageNumber: data['page_number'] as String?,
        fileSize: castToType<int>(data['file_size']),
        fileHash: data['file_hash'] as String?,
        detectedLanguage: data['detected_language'] as String?,
        ocrStatus: data['ocr_status'] as String?,
        isCropped: data['is_cropped'] as bool?,
        createdAt: data['created_at'] as String?,
        updatedAt: data['updated_at'] as String?,
      );

  static PostImageResponseStruct? maybeFromMap(dynamic data) => data is Map
      ? PostImageResponseStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'chapter_id': _chapterId,
        'object_key': _objectKey,
        'filename': _filename,
        'sequence_number': _sequenceNumber,
        'page_number': _pageNumber,
        'file_size': _fileSize,
        'file_hash': _fileHash,
        'detected_language': _detectedLanguage,
        'ocr_status': _ocrStatus,
        'is_cropped': _isCropped,
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
        'page_number': serializeParam(
          _pageNumber,
          ParamType.String,
        ),
        'file_size': serializeParam(
          _fileSize,
          ParamType.int,
        ),
        'file_hash': serializeParam(
          _fileHash,
          ParamType.String,
        ),
        'detected_language': serializeParam(
          _detectedLanguage,
          ParamType.String,
        ),
        'ocr_status': serializeParam(
          _ocrStatus,
          ParamType.String,
        ),
        'is_cropped': serializeParam(
          _isCropped,
          ParamType.bool,
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

  static PostImageResponseStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      PostImageResponseStruct(
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
        pageNumber: deserializeParam(
          data['page_number'],
          ParamType.String,
          false,
        ),
        fileSize: deserializeParam(
          data['file_size'],
          ParamType.int,
          false,
        ),
        fileHash: deserializeParam(
          data['file_hash'],
          ParamType.String,
          false,
        ),
        detectedLanguage: deserializeParam(
          data['detected_language'],
          ParamType.String,
          false,
        ),
        ocrStatus: deserializeParam(
          data['ocr_status'],
          ParamType.String,
          false,
        ),
        isCropped: deserializeParam(
          data['is_cropped'],
          ParamType.bool,
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
  String toString() => 'PostImageResponseStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PostImageResponseStruct &&
        id == other.id &&
        chapterId == other.chapterId &&
        objectKey == other.objectKey &&
        filename == other.filename &&
        sequenceNumber == other.sequenceNumber &&
        pageNumber == other.pageNumber &&
        fileSize == other.fileSize &&
        fileHash == other.fileHash &&
        detectedLanguage == other.detectedLanguage &&
        ocrStatus == other.ocrStatus &&
        isCropped == other.isCropped &&
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
        pageNumber,
        fileSize,
        fileHash,
        detectedLanguage,
        ocrStatus,
        isCropped,
        createdAt,
        updatedAt
      ]);
}

PostImageResponseStruct createPostImageResponseStruct({
  int? id,
  int? chapterId,
  String? objectKey,
  String? filename,
  int? sequenceNumber,
  String? pageNumber,
  int? fileSize,
  String? fileHash,
  String? detectedLanguage,
  String? ocrStatus,
  bool? isCropped,
  String? createdAt,
  String? updatedAt,
}) =>
    PostImageResponseStruct(
      id: id,
      chapterId: chapterId,
      objectKey: objectKey,
      filename: filename,
      sequenceNumber: sequenceNumber,
      pageNumber: pageNumber,
      fileSize: fileSize,
      fileHash: fileHash,
      detectedLanguage: detectedLanguage,
      ocrStatus: ocrStatus,
      isCropped: isCropped,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
