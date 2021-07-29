import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<int?> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
      
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).get();
        final List < DocumentSnapshot > documents = result.docs;
        if (documents.length == 0) {
          return 0;
        }
        return 1;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return 2;
    }
  }

  static Future<bool> isMobileAlreadyExists (String mobile) async{
      final QuerySnapshot result =
      await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: mobile).get();
      final List < DocumentSnapshot > documents = result.docs;
      if (documents.length == 0) {
        return false;
      }
      return true;
  }

  static Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}