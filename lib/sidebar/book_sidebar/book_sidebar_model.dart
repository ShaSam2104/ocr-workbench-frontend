import '/components/buttons/book/book_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'book_sidebar_widget.dart' show BookSidebarWidget;
import 'package:flutter/material.dart';

class BookSidebarModel extends FlutterFlowModel<BookSidebarWidget> {
  ///  Local state fields for this component.

  bool isExtended = true;

  ///  State fields for stateful widgets in this component.

  // Model for Book component.
  late BookModel bookModel;

  @override
  void initState(BuildContext context) {
    bookModel = createModel(context, () => BookModel());
  }

  @override
  void dispose() {
    bookModel.dispose();
  }
}
