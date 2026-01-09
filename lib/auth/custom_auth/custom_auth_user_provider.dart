import 'package:rxdart/rxdart.dart';

import 'custom_auth_manager.dart';

class OcrWorkbenchAuthUser {
  OcrWorkbenchAuthUser({required this.loggedIn, this.uid});

  bool loggedIn;
  String? uid;
}

/// Generates a stream of the authenticated user.
BehaviorSubject<OcrWorkbenchAuthUser> ocrWorkbenchAuthUserSubject =
    BehaviorSubject.seeded(OcrWorkbenchAuthUser(loggedIn: false));
Stream<OcrWorkbenchAuthUser> ocrWorkbenchAuthUserStream() =>
    ocrWorkbenchAuthUserSubject
        .asBroadcastStream()
        .map((user) => currentUser = user);
