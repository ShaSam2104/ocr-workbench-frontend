import '/toasts/error_toast/error_toast_widget.dart';
import '/toasts/info_toast/info_toast_widget.dart';
import '/toasts/success_toast/success_toast_widget.dart';
import '/toasts/warning_toast/warning_toast_widget.dart';
import 'package:flutter/material.dart';

Future errorToast(
  BuildContext context, {
  String? notificationDescription,
}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: ErrorToastWidget(
          notificationDescription: notificationDescription!,
        ),
      );
    },
  );

  await Future.delayed(
    Duration(
      milliseconds: 2000,
    ),
  );
}

Future infoToast(
  BuildContext context, {
  required String? notificationDescription,
}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: InfoToastWidget(
          notificationDescription: notificationDescription!,
        ),
      );
    },
  );

  await Future.delayed(
    Duration(
      milliseconds: 2000,
    ),
  );
}

Future warningToast(
  BuildContext context, {
  required String? notificationDescription,
}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: WarningToastWidget(
          notificationDescription: notificationDescription!,
        ),
      );
    },
  );

  await Future.delayed(
    Duration(
      milliseconds: 2000,
    ),
  );
}

Future successToast(
  BuildContext context, {
  required String? notificationDescription,
}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: SuccessToastWidget(
          notificationDescription: notificationDescription!,
        ),
      );
    },
  );

  await Future.delayed(
    Duration(
      milliseconds: 2000,
    ),
  );
}
