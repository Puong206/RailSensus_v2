import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/sensus_model.dart';
import '../../../data/repositories/sensus_repository.dart';
import 'sensus_event.dart';
import 'sensus_state.dart';

class SensusBloc extends Bloc<SensusEvent, SensusState> {
  final SensusRepository sensusRepository;
  
  // Cache to support returning from detail view or updating single items
  List<SensusModel> currentFeed = [];
  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;

  SensusBloc({required this.sensusRepository}) : super(SensusInitial()) {
    on<SensusFetchRequested>(_onFetchRequested);
    on<SensusDetailRequested>(_onDetailRequested);
    on<SensusCreateRequested>(_onCreateRequested);
    on<SensusVoteRequested>(_onVoteRequested);
    on<SensusAddGalleryPhotoRequested>(_onAddGalleryPhotoRequested);
    on<SensusUpdateRequested>(_onUpdateRequested);
    on<SensusDeleteRequested>(_onDeleteRequested);
    on<SensusFeedRestored>(_onFeedRestored);
  }

  Future<void> _onFetchRequested(SensusFetchRequested event, Emitter<SensusState> emit) async {
    emit(SensusLoading(const [], isFirstFetch: true));

    try {
      final response = await sensusRepository.getSensusFeed(
        page: event.page,
        limit: event.limit,
        search: event.search,
      );
      
      currentFeed = response['list'];
      currentPage = response['currentPage'];
      totalPages = response['totalPages'];
      totalItems = response['totalItems'];

      emit(SensusLoaded(
        sensus: currentFeed,
        totalPages: totalPages,
        currentPage: currentPage,
        totalItems: totalItems,
      ));
    } catch (e) {
      emit(SensusError(e.toString()));
    }
  }

  Future<void> _onDetailRequested(SensusDetailRequested event, Emitter<SensusState> emit) async {
    emit(SensusLoading(const [], isFirstFetch: true));
    try {
      final sensus = await sensusRepository.getSensusById(event.sensusId);
      
      // Update item in currentFeed to sync trust score, etc.
      final index = currentFeed.indexWhere((e) => e.id == sensus.id);
      if (index != -1) {
        currentFeed[index] = sensus;
      }
      
      emit(SensusDetailLoaded(sensus));
    } catch (e) {
      emit(SensusError(e.toString()));
    }
  }

  Future<void> _onFeedRestored(SensusFeedRestored event, Emitter<SensusState> emit) async {
    // Restores the feed state with potentially updated items in currentFeed
    emit(SensusLoaded(
      sensus: List.from(currentFeed),
      totalPages: totalPages,
      currentPage: currentPage,
      totalItems: totalItems,
    ));
  }

  Future<void> _onCreateRequested(SensusCreateRequested event, Emitter<SensusState> emit) async {
    try {
      await sensusRepository.createSensus(event.data);
      emit(SensusActionSuccess('Sensus created successfully'));
      add(SensusFetchRequested(page: 1));
    } catch (e) {
      emit(SensusError(e.toString()));
    }
  }

  Future<void> _onVoteRequested(SensusVoteRequested event, Emitter<SensusState> emit) async {
    try {
      await sensusRepository.voteSensus(event.sensusId, event.tipeVote);
      add(SensusDetailRequested(event.sensusId));
    } catch (e) {
      emit(SensusError(e.toString()));
    }
  }

  Future<void> _onAddGalleryPhotoRequested(SensusAddGalleryPhotoRequested event, Emitter<SensusState> emit) async {
    try {
      await sensusRepository.addGalleryPhoto(event.sensusId, event.data);
      emit(SensusActionSuccess('Foto berhasil ditambahkan ke galeri'));
      add(SensusDetailRequested(event.sensusId)); // Refresh detail
    } catch (e) {
      emit(SensusError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(SensusUpdateRequested event, Emitter<SensusState> emit) async {
    try {
      await sensusRepository.updateSensus(event.sensusId, event.data);
      emit(SensusActionSuccess('Data sensus berhasil diperbarui'));
      add(SensusDetailRequested(event.sensusId)); // Refresh detail
    } catch (e) {
      emit(SensusError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(SensusDeleteRequested event, Emitter<SensusState> emit) async {
    try {
      await sensusRepository.deleteSensus(event.sensusId);
      emit(SensusActionSuccess('Sensus berhasil dihapus'));
      add(SensusFetchRequested(page: 1));
    } catch (e) {
      emit(SensusError(e.toString()));
    }
  }
}
