import 'package:equatable/equatable.dart';

abstract class LokomotifEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LokomotifFetchRequested extends LokomotifEvent {
  final int page;
  final int limit;
  final String search;

  LokomotifFetchRequested({this.page = 1, this.limit = 10, this.search = ''});

  @override
  List<Object?> get props => [page, limit, search];
}

class LokomotifCreateRequested extends LokomotifEvent {
  final Map<String, dynamic> data;
  LokomotifCreateRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class LokomotifUpdateRequested extends LokomotifEvent {
  final int id;
  final Map<String, dynamic> data;
  LokomotifUpdateRequested(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class LokomotifDeleteRequested extends LokomotifEvent {
  final int id;
  LokomotifDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}
