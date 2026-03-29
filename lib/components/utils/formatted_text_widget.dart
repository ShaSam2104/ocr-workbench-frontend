import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import '/flutter_flow/flutter_flow_theme.dart';

/// Custom inline syntax to parse <u>...</u> HTML tags as underline elements.
class _UnderlineSyntax extends md.InlineSyntax {
  _UnderlineSyntax() : super(r'<u>(.*?)</u>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final content = match.group(1)!;
    final element = md.Element.text('u', content);
    parser.addNode(element);
    return true;
  }
}

class FormattedTextWidget extends StatelessWidget {
  const FormattedTextWidget({
    super.key,
    required this.text,
    this.selectable = true,
    this.maxLines,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final bool selectable;
  final int? maxLines;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spans = _parseMarkdown(text, theme);

    final textWidget = RichText(
      text: TextSpan(
        children: spans,
        style: theme.bodyMedium,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );

    if (!selectable) {
      return textWidget;
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: theme.bodyMedium,
      ),
      textAlign: textAlign,
    );
  }

  List<InlineSpan> _parseMarkdown(String text, FlutterFlowTheme theme) {
    final spans = <InlineSpan>[];

    // Parse markdown inline elements from the text
    // Custom syntaxes for HTML tags not natively handled by the markdown parser
    final document = md.Document(
      inlineSyntaxes: [_UnderlineSyntax()],
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
    final parser = md.InlineParser(text, document);
    final nodes = parser.parse();

    _processNodes(nodes, spans, theme);

    return spans.isNotEmpty
        ? spans
        : [
            TextSpan(
              text: text,
              style: theme.bodyMedium,
            ),
          ];
  }

  void _processNodes(
    List<md.Node> nodes,
    List<InlineSpan> spans,
    FlutterFlowTheme theme,
  ) {
    for (final node in nodes) {
      if (node is md.Text) {
        spans.add(
          TextSpan(
            text: node.text,
            style: theme.bodyMedium,
          ),
        );
      } else if (node is md.Element) {
        _processElement(node, spans, theme);
      }
    }
  }

  void _processElement(
    md.Element element,
    List<InlineSpan> spans,
    FlutterFlowTheme theme,
  ) {
    final childSpans = <InlineSpan>[];

    // Process element's children recursively
    if (element.children != null && element.children!.isNotEmpty) {
      _processNodes(element.children!, childSpans, theme);
    }

    // Apply styling based on element tag
    switch (element.tag) {
      case 'strong':
        spans.add(
          TextSpan(
            children: childSpans.isNotEmpty
                ? childSpans
                : [
                    TextSpan(
                      text: element.textContent,
                      style: theme.bodyMedium,
                    )
                  ],
            style: theme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'em':
        spans.add(
          TextSpan(
            children: childSpans.isNotEmpty
                ? childSpans
                : [
                    TextSpan(
                      text: element.textContent,
                      style: theme.bodyMedium,
                    )
                  ],
            style: theme.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case 'code':
        spans.add(
          TextSpan(
            text: element.textContent,
            style: theme.bodyMedium.copyWith(
              fontFamily: 'monospace',
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
        );
      case 'u':
      case 'ins':
        spans.add(
          TextSpan(
            children: childSpans.isNotEmpty
                ? childSpans
                : [
                    TextSpan(
                      text: element.textContent,
                      style: theme.bodyMedium,
                    )
                  ],
            style: theme.bodyMedium.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        );
      case 'del':
        spans.add(
          TextSpan(
            children: childSpans.isNotEmpty
                ? childSpans
                : [
                    TextSpan(
                      text: element.textContent,
                      style: theme.bodyMedium,
                    )
                  ],
            style: theme.bodyMedium.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
        );
      case 'a':
        // Link - just display the text with underline
        spans.add(
          TextSpan(
            children: childSpans.isNotEmpty
                ? childSpans
                : [
                    TextSpan(
                      text: element.textContent,
                      style: theme.bodyMedium,
                    )
                  ],
            style: theme.bodyMedium.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      default:
        // For unknown tags, just add the children
        if (childSpans.isNotEmpty) {
          spans.addAll(childSpans);
        } else {
          spans.add(
            TextSpan(
              text: element.textContent,
              style: theme.bodyMedium,
            ),
          );
        }
    }
  }
}
