import 'package:chat_app/widgets/generic_dialog.dart';
import 'package:flutter/material.dart';

showLogoutDialog(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'LogOut',
    content: const Text('Are you sure you want to Log Out?'),
    optionsBuilder: () => {
      'Cancel': false,
      'Log Out': true,
    },
  ).then((value) => value ?? false);
}
