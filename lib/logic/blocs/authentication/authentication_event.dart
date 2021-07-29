part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent {}

class AuthLoadingEvent extends AuthenticationEvent{}

class AuthFailedEvent extends AuthenticationEvent {}