import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/admin_master_repository.dart';
import 'admin_master_event.dart';
import 'admin_master_state.dart';

class AdminMasterBloc extends Bloc<AdminMasterEvent, AdminMasterState> {
  final AdminMasterRepository adminMasterRepository;

  AdminMasterBloc({required this.adminMasterRepository}) : super(AdminMasterInitial()) {
    // Stats
    on<LoadAdminStatsEvent>(_onLoadAdminStats);

    // Kereta
    on<LoadKeretaEvent>(_onLoadKereta);
    on<CreateKeretaEvent>(_onCreateKereta);
    on<UpdateKeretaEvent>(_onUpdateKereta);
    on<DeleteKeretaEvent>(_onDeleteKereta);

    // Depo
    on<LoadDepoEvent>(_onLoadDepo);
    on<CreateDepoEvent>(_onCreateDepo);
    on<UpdateDepoEvent>(_onUpdateDepo);
    on<DeleteDepoEvent>(_onDeleteDepo);

    // Users
    on<LoadUsersEvent>(_onLoadUsers);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  // =======================
  // STATS
  // =======================
  Future<void> _onLoadAdminStats(LoadAdminStatsEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      final stats = await adminMasterRepository.getAdminStats();
      emit(AdminStatsLoaded(stats));
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  // =======================
  // KERETA
  // =======================
  Future<void> _onLoadKereta(LoadKeretaEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      final keretas = await adminMasterRepository.getKereta(search: event.query);
      emit(AdminKeretaLoaded(keretas));
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  Future<void> _onCreateKereta(CreateKeretaEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      await adminMasterRepository.createKereta(event.data);
      emit(const AdminMasterActionSuccess('Data kereta berhasil ditambahkan'));
      add(const LoadKeretaEvent());
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  Future<void> _onUpdateKereta(UpdateKeretaEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      await adminMasterRepository.updateKereta(event.id, event.data);
      emit(const AdminMasterActionSuccess('Data kereta berhasil diperbarui'));
      add(const LoadKeretaEvent());
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  Future<void> _onDeleteKereta(DeleteKeretaEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      await adminMasterRepository.deleteKereta(event.id);
      emit(const AdminMasterActionSuccess('Data kereta berhasil dihapus'));
      add(const LoadKeretaEvent());
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  // =======================
  // DEPO
  // =======================
  Future<void> _onLoadDepo(LoadDepoEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      final depos = await adminMasterRepository.getDepo(search: event.query);
      emit(AdminDepoLoaded(depos));
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  Future<void> _onCreateDepo(CreateDepoEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      await adminMasterRepository.createDepo(event.data);
      emit(const AdminMasterActionSuccess('Data depo berhasil ditambahkan'));
      add(const LoadDepoEvent());
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  Future<void> _onUpdateDepo(UpdateDepoEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      await adminMasterRepository.updateDepo(event.id, event.data);
      emit(const AdminMasterActionSuccess('Data depo berhasil diperbarui'));
      add(const LoadDepoEvent());
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  Future<void> _onDeleteDepo(DeleteDepoEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      await adminMasterRepository.deleteDepo(event.id);
      emit(const AdminMasterActionSuccess('Data depo berhasil dihapus'));
      add(const LoadDepoEvent());
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  // =======================
  // USERS
  // =======================
  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      final users = await adminMasterRepository.getUsers(search: event.query);
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      await adminMasterRepository.updateUser(event.id, event.data);
      emit(const AdminMasterActionSuccess('Data pengguna berhasil diperbarui'));
      add(const LoadUsersEvent());
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<AdminMasterState> emit) async {
    emit(AdminMasterLoading());
    try {
      await adminMasterRepository.deleteUser(event.id);
      emit(const AdminMasterActionSuccess('Data pengguna berhasil dihapus'));
      add(const LoadUsersEvent());
    } catch (e) {
      emit(AdminMasterError(e.toString()));
    }
  }
}
