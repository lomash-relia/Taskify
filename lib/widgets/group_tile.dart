import 'package:chat_app/views/chat_view.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  const GroupTile(
      {Key? key,
      required this.userName,
      required this.groupId,
      required this.groupName})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        nextScreen(context,
            page: ChatView(
              groupId: widget.groupId,
              groupName: widget.groupName,
              userName: widget.userName,
            ));
      },
      child: ListTile(
        leading: CircleAvatar(
          radius: 23,
          child: Text(widget.groupName.substring(0, 1)),
        ),
        title: Text(widget.groupName),
        subtitle: Text('your username - ${widget.userName}'),
      ),
    );
  }
}
