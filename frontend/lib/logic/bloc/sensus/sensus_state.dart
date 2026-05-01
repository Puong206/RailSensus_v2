import 'package:equatable/equatable.dart';
import '../../../data/models/sensus_model.dart';

abstract class SensusState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SensusInitial extends SensusState {}

class SensusLoading extends SensusState {
  final List<SensusModel> oldSensus;
  final bool isFirstFetch;

  SensusLoading(this.oldSensus, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldSensus, isFirstFetch];
}

class SensusLoaded extends SensusState {
  final List<SensusModel> sensus;
  final int totalPages;
  final int currentPage;
  final int totalItems;

  SensusLoaded({
    required this.sensus,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
  });

  @override
  List<Object?> get props => [sensus, totalPages, currentPage, totalItems];
}

class SensusDetailLoaded extends SensusState {
  final SensusModel sensus;
  SensusDetailLoaded(this.sensus);
  @override
  List<Object?> get props => [sensus];
}

class SensusError extends SensusState {
  final String message;
  final List<SensusModel>? oldSensus;
  SensusError(this.message, {this.oldSensus});
  @override
  List<Object?> get props => [message, oldSensus];
}

class SensusActionSuccess extends SensusState {
  final String message;
  SensusActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
