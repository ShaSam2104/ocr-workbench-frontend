import '/components/utils/file_attachment/file_attachment_widget.dart';
import '/components/utils/image_attachment/image_attachment_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'attachments_model.dart';
export 'attachments_model.dart';

class AttachmentsWidget extends StatefulWidget {
  const AttachmentsWidget({
    super.key,
    this.onFileDelete,
  });

  final Future Function()? onFileDelete;

  @override
  State<AttachmentsWidget> createState() => _AttachmentsWidgetState();
}

class _AttachmentsWidgetState extends State<AttachmentsWidget> {
  late AttachmentsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AttachmentsModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 720.0,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              direction: Axis.horizontal,
              runAlignment: WrapAlignment.start,
              verticalDirection: VerticalDirection.down,
              clipBehavior: Clip.none,
              children: [
                wrapWithModel(
                  model: _model.imageAttachmentModel,
                  updateCallback: () => safeSetState(() {}),
                  child: ImageAttachmentWidget(
                    onDelete: () async {
                      await widget.onFileDelete?.call();
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              direction: Axis.horizontal,
              runAlignment: WrapAlignment.start,
              verticalDirection: VerticalDirection.down,
              clipBehavior: Clip.none,
              children: [
                wrapWithModel(
                  model: _model.fileAttachmentModel,
                  updateCallback: () => safeSetState(() {}),
                  child: FileAttachmentWidget(
                    fileName: 'this_is_a_file.pdf',
                    onDelete: () async {
                      await widget.onFileDelete?.call();
                    },
                  ),
                ),
              ],
            ),
          ),
        ].divide(SizedBox(height: 8.0)),
      ),
    );
  }
}
