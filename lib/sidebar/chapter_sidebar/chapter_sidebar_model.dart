import '/components/buttons/chapter/chapter_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chapter_sidebar_widget.dart' show ChapterSidebarWidget;
import 'package:flutter/material.dart';

class ChapterSidebarModel extends FlutterFlowModel<ChapterSidebarWidget> {
  ///  Local state fields for this component.

  bool isExtended = true;

  ///  State fields for stateful widgets in this component.

  // Model for Chapter component.
  late ChapterModel chapterModel;

  @override
  void initState(BuildContext context) {
    chapterModel = createModel(context, () => ChapterModel());
  }

  @override
  void dispose() {
    chapterModel.dispose();
  }
}
