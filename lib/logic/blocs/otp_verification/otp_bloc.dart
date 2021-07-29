import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'otp_event.dart';
part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc() : super(OtpInitial());

  @override
  Stream<OtpState> mapEventToState(
    OtpEvent event,
  ) async* {
    if(event is GetOtpEvent){
      yield OtpGet();
    }
    else if(event is ResendOtpEvent){
      yield OtpInitial();
    }
    // TODO: implement mapEventToState
  }
}
