
import 'package:chat_app/data/authentication/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/logic/bloc_barrel.dart';

import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {

  var phoneController = TextEditingController();
  var otpController = TextEditingController();
  var verificationId;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await FirebaseService.signOutFromGoogle();
        return true;
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                'assets/images/Simply_Chat.png',
                fit: BoxFit.fill,
              ),
            ),

            Positioned(
              bottom: 100,
              child: BlocBuilder<OtpBloc, OtpState>(
                builder: (context, state) {
                  if (state is OtpInitial) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 250,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromRGBO(66, 245, 167, 1), width: 0.5),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent),
                            child: TextField(
                              maxLines: 1,
                              maxLength: 10,
                              controller: phoneController,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                              cursorColor: Color.fromRGBO(66, 245, 167, 1),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Enter phone number",
                                labelStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 15,
                                    bottom: 11,
                                    top: 11,
                                    right: 15),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              bool isPhoneExists = await FirebaseService.isMobileAlreadyExists(phoneController.text.trim());
                              if(isPhoneExists){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Phone number already in use"),
                                  action: SnackBarAction(
                                    label: "Dismiss",
                                    textColor: Colors.black,
                                    onPressed: () =>
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                  ),
                                ));
                              }
                              else {
                                FirebaseAuth _auth = FirebaseAuth.instance;
                                BlocProvider.of<OtpBloc>(context)
                                    .add(GetOtpEvent());
                                var phoneNum = "+91 " +
                                    phoneController.text.toString().trim();
                                await _auth.verifyPhoneNumber(
                                    phoneNumber: phoneNum,
                                    timeout: Duration(seconds: 120),
                                    verificationCompleted: (credential) async {
                                      await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text("Verification completed"),
                                        action: SnackBarAction(
                                          label: "Dismiss",
                                          textColor: Colors.black,
                                          onPressed: () =>
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar(),
                                        ),
                                      ));
                                      User? firebaseUser =
                                          FirebaseAuth.instance.currentUser;
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(firebaseUser!.uid)
                                          .set({
                                        'nickname': firebaseUser.displayName,
                                        'photoUrl': firebaseUser.photoURL,
                                        'id': firebaseUser.uid,
                                        'phone': phoneController.text.trim()
                                      });
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreen()));
                                    },
                                    verificationFailed: (failed) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text("Server error"),
                                        action: SnackBarAction(
                                          label: "Dismiss",
                                          textColor: Colors.black,
                                          onPressed: () =>
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar(),
                                        ),
                                      ));
                                    },
                                    codeSent: (verificationId, code) {
                                      this.verificationId = verificationId;
                                    },
                                    codeAutoRetrievalTimeout: (verificationId) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text("Timed out, try again"),
                                        action: SnackBarAction(
                                          label: "Dismiss",
                                          textColor: Colors.black,
                                          onPressed: () =>
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar(),
                                        ),
                                      ));
                                      BlocProvider.of<OtpBloc>(context)
                                          .add(ResendOtpEvent());
                                    });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 60,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(66, 245, 167, 1),
                                  borderRadius: BorderRadius.circular(25)),
                              child: Text(
                                "Get Otp",
                                style: TextStyle(color: Colors.black, fontSize: 20),
                              ),
                            )
                        )
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.5,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromRGBO(66, 245, 167, 1), width: 0.5),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent),
                            child: TextField(
                              maxLines: 1,
                              maxLength: 6,
                              controller: otpController,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                              cursorColor: Color.fromRGBO(66, 245, 167, 1),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Enter Otp",
                                labelStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 15,
                                    bottom: 11,
                                    top: 11,
                                    right: 15),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  BlocProvider.of<OtpBloc>(context).add(ResendOtpEvent());
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 60,
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(66, 245, 167, 1),
                                      borderRadius: BorderRadius.circular(25)),
                                  child: Text(
                                    "Resend Otp",
                                    style: TextStyle(color: Colors.black, fontSize: 20),
                                  ),
                                )),
                            TextButton(
                                onPressed: () async {
                                  var smsCode  = otpController.text.toString().trim();
                                    PhoneAuthCredential credential =  PhoneAuthProvider.credential(
                                        verificationId: verificationId, smsCode: smsCode);
                                    try{
                                      await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text("Verification completed"),
                                        action: SnackBarAction(
                                          label: "Dismiss",
                                          textColor: Colors.black,
                                          onPressed: () =>
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar(),
                                        ),
                                      ));

                                      User? firebaseUser =
                                          FirebaseAuth.instance.currentUser;
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(firebaseUser!.uid)
                                          .set({
                                        'nickname': firebaseUser.displayName,
                                        'photoUrl': firebaseUser.photoURL,
                                        'id': firebaseUser.uid,
                                        'phone': phoneController.text.trim()
                                      });
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreen()));
                                    }
                                    catch (e){
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text("Wrong Otp"),
                                        action: SnackBarAction(
                                          label: "Dismiss",
                                          textColor: Colors.black,
                                          onPressed: () =>
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar(),
                                        ),
                                      ));
                                    }

                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 60,
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(66, 245, 167, 1),
                                      borderRadius: BorderRadius.circular(25)),
                                  child: Text(
                                    "Submit otp",
                                    style: TextStyle(color: Colors.black, fontSize: 20),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
