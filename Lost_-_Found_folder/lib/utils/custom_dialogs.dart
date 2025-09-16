import 'package:flutter/material.dart';

/// A utility class for showing common dialogs.
class CustomDialogs {
  /// Shows a simple alert dialog with a title, message, and a single 'OK' button.
  static void showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onButtonPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                if (onButtonPressed != null) {
                  onButtonPressed(); // Execute the callback if provided
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog with 'No' and 'Yes' options.
  /// Returns `true` if 'Yes' is pressed, `false` if 'No' is pressed, and `null` if dismissed.
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a persistent loading dialog with a message.
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot dismiss by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hides the currently shown loading dialog.
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}