import '/components/utils/chat_category/chat_category_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'search_modal_widget.dart' show SearchModalWidget;
import 'package:flutter/material.dart';

class SearchModalModel extends FlutterFlowModel<SearchModalWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for ChatCategory component.
  late ChatCategoryModel chatCategoryModel;

  @override
  void initState(BuildContext context) {
    chatCategoryModel = createModel(context, () => ChatCategoryModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    chatCategoryModel.dispose();
  }
}
