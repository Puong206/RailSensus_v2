import 'package:equatable/equatable.dart';
import '../../../data/models/lokomotif_model.dart';

abstract class LokomotifState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LokomotifInitial extends LokomotifState {}

class LokomotifLoading extends LokomotifState {}

class LokomotifLoaded extends LokomotifState {
  final List<LokomotifModel> lokomotifList;
  final int totalPages;
  final int currentPage;
  final int totalItems;

  LokomotifLoaded({
    required this.lokomotifList,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
  });

  @override
  List<Object?> get props => [lokomotifList, totalPages, currentPage, totalItems];
}

class LokomotifError extends LokomotifState {
  final String message;
  LokomotifError(this.message);
  @override
  List<Object?> get props => [message];
}

class LokomotifActionSuccess extends LokomotifState {
  final String message;
  LokomotifActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
