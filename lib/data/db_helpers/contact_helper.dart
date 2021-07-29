import 'package:chat_app/data/models/Users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactHelper{
  static List<User> _users = [];
  
  static Future<void> getAllContactUsers() async {
    _users = [];
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    var retrievedNumbers = [];
    contacts.forEach((element) {
      element.phones!.forEach((number) {
        var parsedNumber = number.value.toString().replaceFirst("+91", '').replaceAll(' ', '').replaceAll('-', '').trim();
        retrievedNumbers.add(parsedNumber);
      });

    });
    retrievedNumbers = retrievedNumbers.toSet().toList();
    var subList = [];
    for(int i=1;i<=retrievedNumbers.length;i++){

      subList.add(retrievedNumbers[i-1]);
      if(i%10==0 || i==retrievedNumbers.length){
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', whereIn: subList)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        documents.forEach((element) {
          print("found : ${element['phone']}");
          _users.add(new User(element['id'], element['nickname'],
              element['photoUrl'],));
        });
        subList = [];
      }
    }
    _users.sort((a,b) => a.nickName.compareTo(b.nickName));
  }

  static List<User> get contactUsers => _users;
  
}