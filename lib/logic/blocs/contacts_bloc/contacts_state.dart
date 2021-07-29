part of 'contacts_bloc.dart';

@immutable
abstract class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactLoad extends ContactsState {}

class ContactLoadNoInternet extends ContactsState {}

class ContactLoadFailed extends ContactsState {}

class ContactsLoaded extends ContactsState {}