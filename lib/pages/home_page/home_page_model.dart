import '/components/chat/empty_chat_state/empty_chat_state_widget.dart';
import '/components/modals/search_modal/search_modal_widget.dart';
import '/components/utils/attachments/attachments_widget.dart';
import '/components/utils/base_input_field/base_input_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/sidebar/book_sidebar/book_sidebar_widget.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  bool? showSearchModal = false;

  bool showAttachments = false;

  bool showEmptyChat = true;

  bool showResponseLoading = false;

  ///  State fields for stateful widgets in this page.

  // Model for Book_Sidebar component.
  late BookSidebarModel bookSidebarModel;
  // Model for EmptyChatState component.
  late EmptyChatStateModel emptyChatStateModel;
  // Model for Attachments component.
  late AttachmentsModel attachmentsModel;
  // Model for BaseInputField component.
  late BaseInputFieldModel baseInputFieldModel;
  // Model for SearchModal component.
  late SearchModalModel searchModalModel;

  @override
  void initState(BuildContext context) {
    bookSidebarModel = createModel(context, () => BookSidebarModel());
    emptyChatStateModel = createModel(context, () => EmptyChatStateModel());
    attachmentsModel = createModel(context, () => AttachmentsModel());
    baseInputFieldModel = createModel(context, () => BaseInputFieldModel());
    searchModalModel = createModel(context, () => SearchModalModel());
  }

  @override
  void dispose() {
    bookSidebarModel.dispose();
    emptyChatStateModel.dispose();
    attachmentsModel.dispose();
    baseInputFieldModel.dispose();
    searchModalModel.dispose();
  }
}
