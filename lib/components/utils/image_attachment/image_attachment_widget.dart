import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'image_attachment_model.dart';
export 'image_attachment_model.dart';

class ImageAttachmentWidget extends StatefulWidget {
  const ImageAttachmentWidget({
    super.key,
    this.onDelete,
  });

  final Future Function()? onDelete;

  @override
  State<ImageAttachmentWidget> createState() => _ImageAttachmentWidgetState();
}

class _ImageAttachmentWidgetState extends State<ImageAttachmentWidget> {
  late ImageAttachmentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageAttachmentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.0,
      height: 64.0,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              'https://s3-alpha-sig.figma.com/img/8edc/82de/970652999e82613f3c3525d1db5fb12e?Expires=1743379200&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=ZRj5dT~6d7fDMVwj3YUz-pSV4HXvCFKdDKg2YFXBx-Lvkc7tSbdyrr-AD544XC9ZhBsUKWRLXdkjPgQbXhJ-X7m~RvzTBoGt0d~n2Yf1WWfKe2p1dnGEMFpGfQFpc509M14xzsAWE2gOqevBrwirDkMA4S3Xkul0zobeqJQioE8hpZfJu-N6AEzPhs~zKruKlKQc9Vxo4mqqxEQ3aoqX-UMo~AM7yNpICK0N1MURBZOA22LXwNBWsLLwzzb~4S0CgosDHwy~XX~jM-f0JaKQ4S4MumfUjIqo8-9PvKBb3A6QQHiJ8k8n8fl9MabqUvJF71xP8ihoRjjqjkHevtgzOA__',
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: AlignmentDirectional(1.25, -1.25),
            child: Container(
              width: 16.0,
              height: 16.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent4,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  await widget.onDelete?.call();
                },
                child: Icon(
                  Icons.close,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 10.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
