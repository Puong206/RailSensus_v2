import 'package:equatable/equatable.dart';
import '../../../data/models/kereta_model.dart';
import '../../../data/models/depo_model.dart';
import '../../../data/models/user_model.dart';

abstract class AdminMasterState extends Equatable {
  const AdminMasterState();
  
  @override
  List<Object?> get props => [];
}

class AdminMasterInitial extends AdminMasterState {}

class AdminMasterLoading extends AdminMasterState {}

class AdminStatsLoaded extends AdminMasterState {
  final Map<String, dynamic> stats;
  const AdminStatsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class AdminKeretaLoaded extends AdminMasterState {
  final List<KeretaModel> keretas;
  const AdminKeretaLoaded(this.keretas);
  @override
  List<Object?> get props => [keretas];
}

class AdminDepoLoaded extends AdminMasterState {
  final List<DepoModel> depos;
  const AdminDepoLoaded(this.depos);
  @override
  List<Object?> get props => [depos];
}

class AdminUsersLoaded extends AdminMasterState {
  final List<UserModel> users;
  const AdminUsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class AdminMasterActionSuccess extends AdminMasterState {
  final String message;
  const AdminMasterActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminMasterError extends AdminMasterState {
  final String message;
  const AdminMasterError(this.message);
  @override
  List<Object?> get props => [message];
}
