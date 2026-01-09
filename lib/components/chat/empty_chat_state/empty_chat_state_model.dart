import '/components/buttons/book/book_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'empty_chat_state_widget.dart' show EmptyChatStateWidget;
import 'package:flutter/material.dart';

class EmptyChatStateModel extends FlutterFlowModel<EmptyChatStateWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Book component.
  late BookModel bookModel1;
  // Model for Book component.
  late BookModel bookModel2;
  // Model for Book component.
  late BookModel bookModel3;
  // Model for Book component.
  late BookModel bookModel4;

  @override
  void initState(BuildContext context) {
    bookModel1 = createModel(context, () => BookModel());
    bookModel2 = createModel(context, () => BookModel());
    bookModel3 = createModel(context, () => BookModel());
    bookModel4 = createModel(context, () => BookModel());
  }

  @override
  void dispose() {
    bookModel1.dispose();
    bookModel2.dispose();
    bookModel3.dispose();
    bookModel4.dispose();
  }
}
