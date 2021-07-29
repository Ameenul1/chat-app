import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_app/data/db_helpers/contact_helper.dart';
import 'package:meta/meta.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc() : super(ContactsInitial());

  static Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
     if(event is GetRelatedContacts){
       yield ContactLoad();
       var isConnected = await checkInternet();
       if(isConnected){
         try{
           await ContactHelper.getAllContactUsers();
           yield ContactsLoaded();
         }
         catch (e){
           print(e);
           yield ContactLoadFailed();
         }

       }
       else{
         yield ContactLoadNoInternet();
       }
     }
    // TODO: implement mapEventToState
  }
}
