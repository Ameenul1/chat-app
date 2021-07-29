part of 'otp_bloc.dart';

@immutable
abstract class OtpEvent {}

class GetOtpEvent extends OtpEvent{}

class ResendOtpEvent extends OtpEvent{}

