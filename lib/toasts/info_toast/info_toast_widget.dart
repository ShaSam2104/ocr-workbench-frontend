import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'info_toast_model.dart';
export 'info_toast_model.dart';

class InfoToastWidget extends StatefulWidget {
  const InfoToastWidget({
    super.key,
    required this.notificationDescription,
  });

  final String? notificationDescription;

  @override
  State<InfoToastWidget> createState() => _InfoToastWidgetState();
}

class _InfoToastWidgetState extends State<InfoToastWidget>
    with SingleTickerProviderStateMixin {
  late InfoToastModel _model;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InfoToastModel());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 75.0),
            child: Focus(
              onKeyEvent: (node, event) {
                if (HardwareKeyboard.instance
                    .isLogicalKeyPressed(LogicalKeyboardKey.escape)) {
                  _dismiss();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.92,
                constraints: BoxConstraints(
                  maxWidth: 400.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1ECF1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: const Color(0xFFBEE5EB),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.info,
                          color: const Color(0xFF31708F),
                          size: 20.0,
                        ),
                        Text(
                          'Info',
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                ),
                                color: const Color(0xFF31708F),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional(1.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: _dismiss,
                              child: Icon(
                                Icons.close,
                                color: const Color(0xFF31708F)
                                    .withValues(alpha: 0.6),
                                size: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ]
                          .divide(SizedBox(width: 8.0))
                          .addToStart(SizedBox(width: 10.0))
                          .addToEnd(SizedBox(width: 10.0)),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 10.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget.notificationDescription,
                          'This is an informational message',
                        ),
                        style: FlutterFlowTheme.of(context)
                            .labelMedium
                            .override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w400,
                              ),
                              color: const Color(0xFF31708F)
                                  .withValues(alpha: 0.9),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
                      .divide(SizedBox(height: 6.0))
                      .addToStart(SizedBox(height: 10.0))
                      .addToEnd(SizedBox(height: 10.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
