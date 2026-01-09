// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ListBooksDataTypeStruct extends BaseStruct {
  ListBooksDataTypeStruct({
    List<ItemsStruct>? items,
    int? total,
    int? page,
    int? pageSize,
  })  : _items = items,
        _total = total,
        _page = page,
        _pageSize = pageSize;

  // "items" field.
  List<ItemsStruct>? _items;
  List<ItemsStruct> get items => _items ?? const [];
  set items(List<ItemsStruct>? val) => _items = val;

  void updateItems(Function(List<ItemsStruct>) updateFn) {
    updateFn(_items ??= []);
  }

  bool hasItems() => _items != null;

  // "total" field.
  int? _total;
  int get total => _total ?? 0;
  set total(int? val) => _total = val;

  void incrementTotal(int amount) => total = total + amount;

  bool hasTotal() => _total != null;

  // "page" field.
  int? _page;
  int get page => _page ?? 0;
  set page(int? val) => _page = val;

  void incrementPage(int amount) => page = page + amount;

  bool hasPage() => _page != null;

  // "page_size" field.
  int? _pageSize;
  int get pageSize => _pageSize ?? 0;
  set pageSize(int? val) => _pageSize = val;

  void incrementPageSize(int amount) => pageSize = pageSize + amount;

  bool hasPageSize() => _pageSize != null;

  static ListBooksDataTypeStruct fromMap(Map<String, dynamic> data) =>
      ListBooksDataTypeStruct(
        items: getStructList(
          data['items'],
          ItemsStruct.fromMap,
        ),
        total: castToType<int>(data['total']),
        page: castToType<int>(data['page']),
        pageSize: castToType<int>(data['page_size']),
      );

  static ListBooksDataTypeStruct? maybeFromMap(dynamic data) => data is Map
      ? ListBooksDataTypeStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'items': _items?.map((e) => e.toMap()).toList(),
        'total': _total,
        'page': _page,
        'page_size': _pageSize,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'items': serializeParam(
          _items,
          ParamType.DataStruct,
          isList: true,
        ),
        'total': serializeParam(
          _total,
          ParamType.int,
        ),
        'page': serializeParam(
          _page,
          ParamType.int,
        ),
        'page_size': serializeParam(
          _pageSize,
          ParamType.int,
        ),
      }.withoutNulls;

  static ListBooksDataTypeStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ListBooksDataTypeStruct(
        items: deserializeStructParam<ItemsStruct>(
          data['items'],
          ParamType.DataStruct,
          true,
          structBuilder: ItemsStruct.fromSerializableMap,
        ),
        total: deserializeParam(
          data['total'],
          ParamType.int,
          false,
        ),
        page: deserializeParam(
          data['page'],
          ParamType.int,
          false,
        ),
        pageSize: deserializeParam(
          data['page_size'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'ListBooksDataTypeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ListBooksDataTypeStruct &&
        listEquality.equals(items, other.items) &&
        total == other.total &&
        page == other.page &&
        pageSize == other.pageSize;
  }

  @override
  int get hashCode => const ListEquality().hash([items, total, page, pageSize]);
}

ListBooksDataTypeStruct createListBooksDataTypeStruct({
  int? total,
  int? page,
  int? pageSize,
}) =>
    ListBooksDataTypeStruct(
      total: total,
      page: page,
      pageSize: pageSize,
    );
