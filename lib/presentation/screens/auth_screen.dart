import 'package:chat_app/data/authentication/authentication.dart';
import 'package:chat_app/logic/bloc_barrel.dart';
import 'package:chat_app/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'otp_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            bottom: 80,
            child: BlocListener<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                if (state is AuthenticationErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Sign in failed, Check your connection"),
                    action: SnackBarAction(
                      label: "Dismiss",
                      textColor: Colors.black,
                      onPressed: () =>
                          ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    ),
                  ));
                }
              },
              child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                builder: (context, state) {
                  if (state is AuthenticationLoadingState) {
                    return CircularProgressIndicator(
                      color: Color.fromRGBO(66, 245, 167, 1),
                    );
                  } else {
                    return TextButton(
                        onPressed: () async {
                          try {
                            int? val = await FirebaseService.signInwithGoogle();
                            if(val == 0){
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => OTPScreen()));
                            }
                            else if(val == 1){
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Sign in failed"),
                                action: SnackBarAction(
                                  label: "Dismiss",
                                  textColor: Colors.black,
                                  onPressed: () =>
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                ),
                              ));
                            }
                          } catch (e) {
                            print(e);
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
                            "Sign up",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ));
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
