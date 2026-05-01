import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/lokomotif_repository.dart';
import 'lokomotif_event.dart';
import 'lokomotif_state.dart';

class LokomotifBloc extends Bloc<LokomotifEvent, LokomotifState> {
  final LokomotifRepository lokomotifRepository;

  LokomotifBloc({required this.lokomotifRepository}) : super(LokomotifInitial()) {
    on<LokomotifFetchRequested>(_onFetchRequested);
    on<LokomotifCreateRequested>(_onCreateRequested);
    on<LokomotifUpdateRequested>(_onUpdateRequested);
    on<LokomotifDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onFetchRequested(LokomotifFetchRequested event, Emitter<LokomotifState> emit) async {
    emit(LokomotifLoading());
    try {
      final response = await lokomotifRepository.getLokomotifList(
        page: event.page,
        limit: event.limit,
        search: event.search,
      );
      emit(LokomotifLoaded(
        lokomotifList: response['list'],
        totalPages: response['totalPages'],
        currentPage: event.page,
        totalItems: response['totalItems'],
      ));
    } catch (e) {
      emit(LokomotifError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(LokomotifCreateRequested event, Emitter<LokomotifState> emit) async {
    try {
      await lokomotifRepository.createLokomotif(event.data);
      emit(LokomotifActionSuccess('Lokomotif berhasil ditambahkan'));
    } catch (e) {
      emit(LokomotifError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(LokomotifUpdateRequested event, Emitter<LokomotifState> emit) async {
    try {
      await lokomotifRepository.updateLokomotif(event.id, event.data);
      emit(LokomotifActionSuccess('Lokomotif berhasil diperbarui'));
    } catch (e) {
      emit(LokomotifError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(LokomotifDeleteRequested event, Emitter<LokomotifState> emit) async {
    try {
      await lokomotifRepository.deleteLokomotif(event.id);
      emit(LokomotifActionSuccess('Lokomotif berhasil dihapus'));
    } catch (e) {
      emit(LokomotifError(e.toString()));
    }
  }
}
