import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/data/models/Users.dart' as local;
import 'package:async/async.dart';
import 'message_bubble.dart';

class Messages extends StatefulWidget {
  final local.User otherPersonDetails;
  Messages(this.otherPersonDetails);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  Stream<List<QuerySnapshot>> getData() {
    Stream<QuerySnapshot> stream1 = FirebaseFirestore.instance
        .collection('chat')
        .where('senderId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
        .where('receiverId', isEqualTo: widget.otherPersonDetails.id)
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
    Stream<QuerySnapshot> stream2 = FirebaseFirestore.instance
        .collection('chat')
        .where('senderId', isEqualTo: widget.otherPersonDetails.id)
        .where('receiverId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
    return StreamZip([stream1, stream2]).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .where('senderId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
            .where('receiverId', isEqualTo: widget.otherPersonDetails.id)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, snapshot1) {
          if (snapshot1.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .where('senderId', isEqualTo: widget.otherPersonDetails.id)
                  .where('receiverId',
                      isEqualTo:
                          FirebaseAuth.instance.currentUser!.uid.toString())
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (ctx, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot1.hasData && !snapshot2.hasData) {
                  return Center(
                    child: Text("Start a chat"),
                  );
                }

                final chatDocs = snapshot1.data!.docs + snapshot2.data!.docs;
                chatDocs.sort((a, b) {
                  var date1 = DateTime.fromMillisecondsSinceEpoch(
                      a['createdAt'].microsecondsSinceEpoch);
                  var date2 = DateTime.fromMillisecondsSinceEpoch(
                      b['createdAt'].microsecondsSinceEpoch);
                  return date2.compareTo(date1);
                });
                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) => MessageBubble(
                    chatDocs[index]['text'],
                    chatDocs[index]['senderName'],
                    chatDocs[index]['senderImage'],
                    chatDocs[index]['senderId'] ==
                        FirebaseAuth.instance.currentUser!.uid,
                    key: ValueKey(chatDocs[index].id),
                  ),
                );
              });
        });
  }
}
