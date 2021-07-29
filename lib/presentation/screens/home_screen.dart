import 'package:chat_app/data/authentication/authentication.dart';
import 'package:chat_app/presentation/screens/auth_screen.dart';
import 'package:chat_app/presentation/screens/chat_screen.dart';
import 'package:chat_app/presentation/screens/contacts_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_app/data/models/Users.dart' as local;


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  User? _user = FirebaseAuth.instance.currentUser!;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundImage: NetworkImage(_user!.photoURL!),
          ),
        ),
        title: Text(_user!.displayName!,style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromRGBO(25,25,50,1),
        actions: [
          IconButton(
              onPressed: () async {
                try{
                  await FirebaseService.signOutFromGoogle();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AuthScreen())
                  );
                }
                catch (e){
                  print(e);
                }
              },
              icon: Icon(Icons.logout,color: Colors.white,)
          )
        ],
      ),
      backgroundColor: Color.fromRGBO(25,26,40,1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final PermissionStatus permissionStatus = await Permission.contacts.request();
          if (permissionStatus == PermissionStatus.granted) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ContactsScreen()));
          } else {
            //If permissions have been denied show standard cupertino alert dialog
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text("Permission denied, Allow access to contacts"),
              action: SnackBarAction(
                label: "Dismiss",
                textColor: Colors.black,
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ));
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.contact_page_rounded,color: Color.fromRGBO(17,25,50,1),),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream:
          FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('lastChats').snapshots(),

          builder: (ctx, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final chatDocs = chatSnapshot.data!.docs;
            if(chatDocs.length==0){
              return Center(
                child: Text("No chats found",style: TextStyle(color: Colors.grey)),
              );
            }
             return ListView.builder(
                 itemCount: chatDocs.length,
                 itemBuilder: (context,index) => Container(
                   height: 80,
                   decoration: BoxDecoration(
                       border: Border(bottom: BorderSide(color: Colors.grey,width: 0.5))
                   ),
                   child: ListTile(
                     leading: CircleAvatar(
                       backgroundImage: NetworkImage(chatDocs[index]['photoUrl']),
                     ),
                     title: Text(chatDocs[index]['name'],style: TextStyle(color: Colors.white),),
                     subtitle: Text(chatDocs[index]['message'],style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis,),
                     onTap: () =>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatScreen(new local.User(
                         chatDocs[index].id,chatDocs[index]['name'],chatDocs[index]['photoUrl']
                     )))),
                     trailing: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(DateTime.fromMicrosecondsSinceEpoch(
                             chatDocs[index]['sentTime'].microsecondsSinceEpoch ).toString().substring(0,10),style: TextStyle(color: Colors.grey)),
                         Text(DateTime.fromMicrosecondsSinceEpoch(
                             chatDocs[index]['sentTime'].microsecondsSinceEpoch ).toString().substring(11,16),style: TextStyle(color: Colors.grey)),
                       ],
                     ),
                   ),
                 )
             );
            
          })
    );
  }
}
