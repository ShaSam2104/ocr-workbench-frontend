import '/components/utils/file_attachment/file_attachment_widget.dart';
import '/components/utils/image_attachment/image_attachment_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'attachments_widget.dart' show AttachmentsWidget;
import 'package:flutter/material.dart';

class AttachmentsModel extends FlutterFlowModel<AttachmentsWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for ImageAttachment component.
  late ImageAttachmentModel imageAttachmentModel;
  // Model for FileAttachment component.
  late FileAttachmentModel fileAttachmentModel;

  @override
  void initState(BuildContext context) {
    imageAttachmentModel = createModel(context, () => ImageAttachmentModel());
    fileAttachmentModel = createModel(context, () => FileAttachmentModel());
  }

  @override
  void dispose() {
    imageAttachmentModel.dispose();
    fileAttachmentModel.dispose();
  }
}
