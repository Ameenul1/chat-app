import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/data/models/Users.dart' as local;

class NewMessage extends StatefulWidget {
  final local.User otherPersonDetails;
  NewMessage(this.otherPersonDetails);
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();

  void _sendMessage() async {
    FocusScope.of(context).requestFocus();
    var testMessage = _controller.text.toString();
    _controller.clear();
    if(testMessage.isNotEmpty){
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('chat').add({
        'text': testMessage,
        'createdAt': Timestamp.now(),
        'senderId': user.uid,
        'senderName': user.displayName,
        'senderImage': user.photoURL,
        'receiverId': widget.otherPersonDetails.id,
        'receiverName': widget.otherPersonDetails.nickName,
        'receiverImage': widget.otherPersonDetails.photoUrl,
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('lastChats').doc(widget.otherPersonDetails.id).set({
        'sentBy' : user.uid,
        'sentTime' : Timestamp.now(),
        'message' : testMessage,
        'name' : widget.otherPersonDetails.nickName,
        'photoUrl' : widget.otherPersonDetails.photoUrl,
      });
      await FirebaseFirestore.instance.collection('users').doc(widget.otherPersonDetails.id).collection('lastChats').doc(user.uid).set({
        'sentBy' : user.uid,
        'sentTime' : Timestamp.now(),
        'message' : testMessage,
        'name' : user.displayName,
        'photoUrl' : user.photoURL,
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Send a message...',labelStyle: TextStyle(color: Colors.grey)),
              maxLength: 250,
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(
              Icons.send,
            ),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }
}
