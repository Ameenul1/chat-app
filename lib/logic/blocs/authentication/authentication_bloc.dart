import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if(event is AuthFailedEvent){
      yield AuthenticationErrorState();
      yield AuthenticationLoadingState();
    }
    else{
      yield AuthenticationInitial();
    }
    // TODO: implement mapEventToState
  }
}
