import '/flutter_flow/flutter_flow_util.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  bool? showSearchModal = false;
  bool showImageDetailModal = false;
  bool showAudioDetailModal = false;
  bool showExportModal = false;
  bool showConfirmDialog = false;

  int? selectedImageId;
  int? selectedAudioId;
  String? selectedImageUrl;
  String? selectedAudioUrl;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
