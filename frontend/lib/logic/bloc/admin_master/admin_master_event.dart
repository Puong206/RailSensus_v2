import 'package:equatable/equatable.dart';

abstract class AdminMasterEvent extends Equatable {
  const AdminMasterEvent();

  @override
  List<Object?> get props => [];
}

// Stats
class LoadAdminStatsEvent extends AdminMasterEvent {
  const LoadAdminStatsEvent();
}

// Kereta Events
class LoadKeretaEvent extends AdminMasterEvent {
  final String query;
  const LoadKeretaEvent({this.query = ''});
  @override
  List<Object?> get props => [query];
}

class CreateKeretaEvent extends AdminMasterEvent {
  final Map<String, dynamic> data;
  const CreateKeretaEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateKeretaEvent extends AdminMasterEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateKeretaEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteKeretaEvent extends AdminMasterEvent {
  final int id;
  const DeleteKeretaEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// Depo Events
class LoadDepoEvent extends AdminMasterEvent {
  final String query;
  const LoadDepoEvent({this.query = ''});
  @override
  List<Object?> get props => [query];
}

class CreateDepoEvent extends AdminMasterEvent {
  final Map<String, dynamic> data;
  const CreateDepoEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateDepoEvent extends AdminMasterEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateDepoEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteDepoEvent extends AdminMasterEvent {
  final int id;
  const DeleteDepoEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// Users Events
class LoadUsersEvent extends AdminMasterEvent {
  final String query;
  const LoadUsersEvent({this.query = ''});
  @override
  List<Object?> get props => [query];
}

class UpdateUserEvent extends AdminMasterEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateUserEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteUserEvent extends AdminMasterEvent {
  final int id;
  const DeleteUserEvent(this.id);
  @override
  List<Object?> get props => [id];
}
