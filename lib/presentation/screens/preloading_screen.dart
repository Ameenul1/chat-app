import 'package:chat_app/data/authentication/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/logic/bloc_barrel.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final User? _user = FirebaseAuth.instance.currentUser;

  late bool isSignedInProperly;


  Future<void> checkProperAuth() async{
    if (_user != null) {
      final QuerySnapshot result =
      await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: _user!.uid).get();
      final List < DocumentSnapshot > documents = result.docs;
      if (documents.length == 0) {
        isSignedInProperly = false;
        FirebaseService.signOutFromGoogle();
      }
      else{
        isSignedInProperly = true;
      }
    }
    else{
      isSignedInProperly = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(),
        ),
        BlocProvider(
          create: (context) => OtpBloc(),
        ),
        BlocProvider(
          create: (context) => ContactsBloc(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: (_user != null) ?  FutureBuilder(
            future: checkProperAuth(),
            builder: (context,snap) =>(snap.connectionState == ConnectionState.waiting)?Center(child: CircularProgressIndicator()):(isSignedInProperly)?HomeScreen():AuthScreen()
        ) : AuthScreen(),
      ),
    );
  }
}
