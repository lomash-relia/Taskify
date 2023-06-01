import 'package:chat_app/widgets/generic_dialog.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

showCreateGroupDialog(context) {
  final nameController = TextEditingController();
  showGenericDialog(
    context: context,
    title: 'Create New Group',
    content: TextField(
      controller: nameController,
      decoration: textInputDecoration.copyWith(labelText: 'Group Name'),
    ),
    optionsBuilder: () => {
      'Cancel': false,
      'Create': nameController.text,
    },
  );
}
