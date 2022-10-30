import 'package:firebase_app/auth/auth_error.dart';
import 'package:firebase_app/dialogs/generic_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show BuildContext;

Future<void> showAuthError({
  required AuthError authError,
  required BuildContext context,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionsBuilder: () => {
      'OK': true,
    },
  );
}