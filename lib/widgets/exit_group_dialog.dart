import 'package:chat_app/widgets/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showExitGroupDialog(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'Exit',
    content: const Text('Are you sure you want to exit the group?'),
    optionsBuilder: () => {
      'Cancel': false,
      'Exit Group': true,
    },
  ).then((value) => value ?? false);
}
