import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController searchController;
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool _hasUserSearch = false;
  bool _isJoined = false;

  @override
  void initState() {
    searchController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService()
          .searchGroupByName(searchController.text.trim())
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _hasUserSearch = true;
          _isLoading = false;
        });
      });
    }
  }

  groupList() {
    return _hasUserSearch
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              final search = searchSnapshot!.docs[index];
              final String admin = search['admin'];
              return groupTile(
                userName: admin.substring(admin.indexOf('_') + 1),
                groupId: search['groupId'],
                groupName: search['groupName'],
              );
            },
          )
        : Container();
  }

  Widget groupTile(
      {required String userName,
      required String groupId,
      required String groupName}) {
    joinedOrNot(groupId, groupName, userName);
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        child: Text(groupName.substring(0, 1)),
      ),
      title: Text(groupName),
      subtitle: Text(groupId),
      trailing: GestureDetector(
        onTap: () async {
          final user = FirebaseAuth.instance.currentUser;
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, groupName, userName)
              .then((value) {
            setState(() {
              _isJoined = !_isJoined;
            });
          });
        },
        child: _isJoined
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                child: const Text(
                  'Leave',
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
                child: const Text(
                  'Join',
                ),
              ),
      ),
    );
  }

  void joinedOrNot(String groupId, String groupName, String userName) async {
    final user = FirebaseAuth.instance.currentUser;
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupId, groupName, userName)
        .then((value) {
      setState(() {
        _isJoined = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(children: [
              Expanded(
                  child: TextField(
                controller: searchController,
                decoration: textInputDecoration.copyWith(
                    fillColor: Colors.green, hintText: 'Search Groups'),
              )),
              SizedBox(
                  width: 70,
                  child: IconButton(
                      onPressed: () {
                        initiateSearchMethod();
                      },
                      icon: const Icon(
                        Icons.search,
                      ))),
            ]),
          ),
          _isLoading ? const CircularProgressIndicator() : groupList(),
        ],
      ),
    );
  }
}
