// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ItemsStruct extends BaseStruct {
  ItemsStruct({
    int? id,
    int? bookId,
    String? name,
    String? description,
    int? sequenceOrder,
    String? createdAt,
    String? updatedAt,
  })  : _id = id,
        _bookId = bookId,
        _name = name,
        _description = description,
        _sequenceOrder = sequenceOrder,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "book_id" field.
  int? _bookId;
  int get bookId => _bookId ?? 0;
  set bookId(int? val) => _bookId = val;

  void incrementBookId(int amount) => bookId = bookId + amount;

  bool hasBookId() => _bookId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  set description(String? val) => _description = val;

  bool hasDescription() => _description != null;

  // "sequence_order" field.
  int? _sequenceOrder;
  int get sequenceOrder => _sequenceOrder ?? 0;
  set sequenceOrder(int? val) => _sequenceOrder = val;

  void incrementSequenceOrder(int amount) =>
      sequenceOrder = sequenceOrder + amount;

  bool hasSequenceOrder() => _sequenceOrder != null;

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

  static ItemsStruct fromMap(Map<String, dynamic> data) => ItemsStruct(
        id: castToType<int>(data['id']),
        bookId: castToType<int>(data['book_id']),
        name: data['name'] as String?,
        description: data['description'] as String?,
        sequenceOrder: castToType<int>(data['sequence_order']),
        createdAt: data['created_at'] as String?,
        updatedAt: data['updated_at'] as String?,
      );

  static ItemsStruct? maybeFromMap(dynamic data) =>
      data is Map ? ItemsStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'book_id': _bookId,
        'name': _name,
        'description': _description,
        'sequence_order': _sequenceOrder,
        'created_at': _createdAt,
        'updated_at': _updatedAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'book_id': serializeParam(
          _bookId,
          ParamType.int,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'description': serializeParam(
          _description,
          ParamType.String,
        ),
        'sequence_order': serializeParam(
          _sequenceOrder,
          ParamType.int,
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

  static ItemsStruct fromSerializableMap(Map<String, dynamic> data) =>
      ItemsStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        bookId: deserializeParam(
          data['book_id'],
          ParamType.int,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        description: deserializeParam(
          data['description'],
          ParamType.String,
          false,
        ),
        sequenceOrder: deserializeParam(
          data['sequence_order'],
          ParamType.int,
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
  String toString() => 'ItemsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ItemsStruct &&
        id == other.id &&
        bookId == other.bookId &&
        name == other.name &&
        description == other.description &&
        sequenceOrder == other.sequenceOrder &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => const ListEquality().hash(
      [id, bookId, name, description, sequenceOrder, createdAt, updatedAt]);
}

ItemsStruct createItemsStruct({
  int? id,
  int? bookId,
  String? name,
  String? description,
  int? sequenceOrder,
  String? createdAt,
  String? updatedAt,
}) =>
    ItemsStruct(
      id: id,
      bookId: bookId,
      name: name,
      description: description,
      sequenceOrder: sequenceOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
