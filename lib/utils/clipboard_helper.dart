/// Platform-agnostic clipboard helper
/// Uses conditional imports to support web, mobile, and desktop
library;

// Conditional import: use web implementation if dart:html is available
// Otherwise use mobile/desktop implementation
import 'clipboard_helper_stub.dart'
    if (dart.library.html) 'clipboard_helper_web.dart';

// Re-export the copyToClipboard function from the conditionally imported file
export 'clipboard_helper_stub.dart' if (dart.library.html) 'clipboard_helper_web.dart';

