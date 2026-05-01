import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  AuthRegisterRequested(this.username, this.email, this.password);

  @override
  List<Object?> get props => [username, email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateProfileRequested extends AuthEvent {
  final String username;
  final String email;

  AuthUpdateProfileRequested(this.username, this.email);

  @override
  List<Object?> get props => [username, email];
}

class AuthProfilePhotoUpdated extends AuthEvent {
  final File image;

  AuthProfilePhotoUpdated(this.image);

  @override
  List<Object?> get props => [image];
}

class AuthProfilePhotoDeleted extends AuthEvent {}

class AuthChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  AuthChangePasswordRequested(this.oldPassword, this.newPassword);

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
