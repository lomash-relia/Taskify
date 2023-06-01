import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/views/auth/login_view.dart';
import 'package:chat_app/views/search_view.dart';
import 'package:chat_app/widgets/group_tile.dart';
import 'package:chat_app/widgets/logout_dialog.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AuthService authService;
  String? userName;
  String? userEmail;
  late String? groupName;
  bool _isLoading = false;
  Stream? groups;

  @override
  void initState() {
    super.initState();
    gettingUserData();
    authService = AuthService();
  }

  void gettingUserData() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      if (value != null) {
        setState(() {
          userName = value;
        });
      }
    });
    await HelperFunctions.getUserEmailFromSF().then((value) {
      if (value != null) {
        setState(() {
          userEmail = value;
        });
      }
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  Widget noGroupWidget() {
    return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 60,
          ),
          SizedBox(height: 15, width: double.maxFinite),
          Text(
            'No Groups Joined Yet',
            style: TextStyle(
              fontSize: 30,
            ),
          )
        ]);
  }

  String getID(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  StreamBuilder groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data['groups'] != null) {
          if (snapshot.data['groups'].length != 0) {
            final count = snapshot.data['groups'].length;

            return ListView.builder(
              itemCount: count,
              itemBuilder: (context, index) {
                final int reverseCount = count - index - 1;
                final List groupsList = snapshot.data['groups'];
                return GroupTile(
                  userName: snapshot.data['fullName'],
                  groupId: getID(groupsList[reverseCount]),
                  groupName: getName(groupsList[reverseCount]),
                );
              },
            );
          } else {
            return noGroupWidget();
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create a Group'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  (_isLoading == true)
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : TextField(
                          onChanged: (value) {
                            setState(() {
                              groupName = value;
                            });
                          },
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Group Name',
                          ),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      prevScreen(context);
                    },
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () async {
                      if (groupName != '') {
                        setState(() {
                          _isLoading = true;
                        });

                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        DatabaseService(uid: userId)
                            .createGroup(
                                userName: userName!,
                                id: userId,
                                groupName: groupName!.trim())
                            .whenComplete(() {
                          _isLoading = false;
                        });
                        showSnack(context, '$groupName Created', Colors.green);
                        prevScreen(context);
                      }
                    },
                    child: const Text('Create'))
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(
              height: 15,
            ),
            const Icon(
              Icons.person_rounded,
              size: 75,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () {
                nextScreen(context, page: const SearchView());
              },
              selected: true,
              title: const Text('Search Groups'),
              leading: const Icon(Icons.group),
              iconColor: Colors.green,
            ),
            const Divider(
              thickness: 3,
            ),
            ListTile(
                leading: const Icon(Icons.logout),
                onTap: () async {
                  bool shouldLogOut = await showLogoutDialog(context);

                  if (shouldLogOut && mounted) {
                    authService.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                        (route) => false);
                  }
                },
                title: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
          ]),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Groups',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
      ),
      body: groupList(),
    );
  }
}
