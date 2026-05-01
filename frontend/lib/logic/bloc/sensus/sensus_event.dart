import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

abstract class SensusEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SensusFetchRequested extends SensusEvent {
  final int page;
  final int limit;
  final String search;

  SensusFetchRequested({this.page = 1, this.limit = 10, this.search = ''});
  @override
  List<Object?> get props => [page, limit, search];
}

class SensusDetailRequested extends SensusEvent {
  final int sensusId;
  SensusDetailRequested(this.sensusId);
  @override
  List<Object?> get props => [sensusId];
}

class SensusCreateRequested extends SensusEvent {
  final FormData data;
  SensusCreateRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class SensusVoteRequested extends SensusEvent {
  final int sensusId;
  final String tipeVote;
  SensusVoteRequested(this.sensusId, this.tipeVote);
  @override
  List<Object?> get props => [sensusId, tipeVote];
}

class SensusAddGalleryPhotoRequested extends SensusEvent {
  final int sensusId;
  final FormData data;
  SensusAddGalleryPhotoRequested(this.sensusId, this.data);
  @override
  List<Object?> get props => [sensusId, data];
}

class SensusUpdateRequested extends SensusEvent {
  final int sensusId;
  final Map<String, dynamic> data;
  SensusUpdateRequested(this.sensusId, this.data);
  @override
  List<Object?> get props => [sensusId, data];
}

class SensusDeleteRequested extends SensusEvent {
  final int sensusId;
  SensusDeleteRequested(this.sensusId);
  @override
  List<Object?> get props => [sensusId];
}

class SensusFeedRestored extends SensusEvent {}

