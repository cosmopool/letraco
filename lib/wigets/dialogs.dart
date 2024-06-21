import 'package:flutter/material.dart';

Future<void> showTwoButtonsDialog(
  BuildContext context, {
  required String title,
  required String content,
  required VoidCallback onPressedOk,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Não'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: onPressedOk,
            child: const Text('Sim'),
          ),
        ],
      );
    },
  );
}

Future<void> showNoButtonsDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
      );
    },
  );
}
