import '/components/chat/chat_response_feedback/chat_response_feedback_widget.dart';
import '/components/skeletons/image_skeleton/image_skeleton_widget.dart';
import '/components/skeletons/text_skeleton/text_skeleton_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chat_response_a_i_widget.dart' show ChatResponseAIWidget;
import 'package:flutter/material.dart';

class ChatResponseAIModel extends FlutterFlowModel<ChatResponseAIWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for TextSkeleton component.
  late TextSkeletonModel textSkeletonModel;
  // Model for ImageSkeleton component.
  late ImageSkeletonModel imageSkeletonModel;
  // Model for ChatResponseFeedback component.
  late ChatResponseFeedbackModel chatResponseFeedbackModel;

  @override
  void initState(BuildContext context) {
    textSkeletonModel = createModel(context, () => TextSkeletonModel());
    imageSkeletonModel = createModel(context, () => ImageSkeletonModel());
    chatResponseFeedbackModel =
        createModel(context, () => ChatResponseFeedbackModel());
  }

  @override
  void dispose() {
    textSkeletonModel.dispose();
    imageSkeletonModel.dispose();
    chatResponseFeedbackModel.dispose();
  }
}
