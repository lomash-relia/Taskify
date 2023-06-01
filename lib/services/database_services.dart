import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

//reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  //updating user data
  Future<void> saveUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": '',
      "uid": uid,
    });
  }

//getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

// getting user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

//creating group
  Future createGroup({
    required String userName,
    required String id,
    required String groupName,
  }) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupId": '',
      "groupIcon": '',
      "members": '',
      "admin": '${id}_$userName',
      "recentMessage": '',
      "recentMessageSender": '',
      "recentMessageTime": '',
    });

    //update members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

//getting chat data
  Future<Stream<QuerySnapshot>> getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

//search
  Future searchGroupByName(String groupName) async {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }

//user joined?
  Future<bool> isUserJoined(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List groups = await documentSnapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      return true;
    }
    return false;
  }

  //
  Future toggleGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List groups = await documentSnapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      await userDocumentReference.update({
        'groups': FieldValue.arrayRemove(['${groupId}_$groupName']),
      });
      await groupDocumentReference.update({
        'members': FieldValue.arrayRemove(['${uid}_$userName']),
      });
    } else {
      await userDocumentReference.update({
        'groups': FieldValue.arrayUnion(['${groupId}_$groupName']),
      });
      await groupDocumentReference.update({
        'members': FieldValue.arrayUnion(['${uid}_$userName']),
      });
    }
  }

  //send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection('messages').add(chatMessageData);

    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
