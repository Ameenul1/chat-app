import 'package:chat_app/data/db_helpers/contact_helper.dart';
import 'package:chat_app/logic/blocs/contacts_bloc/contacts_bloc.dart';
import 'package:chat_app/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts", style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromRGBO(25,25,50,1),
      ),
      backgroundColor: Color.fromRGBO(25,26,40,1),
      body: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
          if(state is ContactLoad){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else if(state is ContactsLoaded){
            var contacts = ContactHelper.contactUsers;
            if(contacts.length==0){
              return Center(
                child: Container(
                  child: Text("No contacts in your phone use this app",style: TextStyle(color: Colors.white),),
                ),
              );
            }
            else{
              return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context,i) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(contacts[i].photoUrl),

                    ),
                    title: Text(contacts[i].nickName,style: TextStyle(color: Colors.white),),
                    onTap: () =>Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>ChatScreen(contacts[i]))),
                  )
              );
            }
          }
          else if(state is ContactLoadNoInternet){
            return Center(
              child: Container(
                child: Text("No Internet Connection",style: TextStyle(color: Colors.white),),
              ),
            );
          }
          else if(state is ContactLoadFailed){
            return Center(
              child: Container(
                child: Text("Contacts sync failed",style: TextStyle(color: Colors.white),),
              ),
            );
          }
          else{
            BlocProvider.of<ContactsBloc>(context).add(GetRelatedContacts());
            return Center(
              child: Container(
                child: Text("No contacts in your phone use this app",style: TextStyle(color: Colors.white),),
              ),
            );
          }
        },
      ),
    );
  }
}
