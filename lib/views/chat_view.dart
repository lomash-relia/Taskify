import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/widgets/exit_group_dialog.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatView(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  Stream<QuerySnapshot>? chats;
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    getChat();
    super.initState();
  }

  getChat() async {
    await DatabaseService().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final message = snapshot.data?.docs[index];
                  return MessageTile(
                      message: message['message'],
                      sender: message['sender'],
                      sentByMe: widget.userName == message['sender']);
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'message': messageController.text,
        'sender': widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () async {
                bool shouldExit = await showExitGroupDialog(context);
                if (shouldExit) {
                  await DatabaseService(
                          uid: FirebaseAuth.instance.currentUser!.uid)
                      .toggleGroupJoin(
                          widget.groupId, widget.groupName, widget.userName);
                }
                if (mounted) {
                  prevScreen(context);
                }
              },
              icon: const Icon(Icons.exit_to_app_outlined))
        ],
      ),
      body: Stack(children: [
        chatMessages(),
        Container(
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(children: [
              Expanded(
                child: TextFormField(
                  controller: messageController,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Send a Message...'),
                ),
              ),
              IconButton(
                onPressed: () {
                  sendMessage();
                },
                icon: const Icon(Icons.arrow_upward_outlined),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
