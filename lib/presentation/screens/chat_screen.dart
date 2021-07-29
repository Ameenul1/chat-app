import 'package:chat_app/data/models/Users.dart';
import 'package:chat_app/presentation/widgets/messages.dart';
import 'package:chat_app/presentation/widgets/new_message.dart';
import 'package:flutter/material.dart';



class ChatScreen extends StatefulWidget {
  final User otherPersonDetails;
  ChatScreen(this.otherPersonDetails);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.otherPersonDetails.photoUrl),
          ),
        ),
        backgroundColor: Color.fromRGBO(25,25,50,1),
        title: Text(widget.otherPersonDetails.nickName),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset('assets/images/chat_body.png',fit: BoxFit.fill,),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Messages(widget.otherPersonDetails),
                ),
                NewMessage(widget.otherPersonDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
