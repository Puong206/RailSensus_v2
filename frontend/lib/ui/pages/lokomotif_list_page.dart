import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/auth/auth_bloc.dart';
import '../../logic/bloc/auth/auth_state.dart';
import '../../logic/bloc/lokomotif/lokomotif_bloc.dart';
import '../../logic/bloc/lokomotif/lokomotif_event.dart';
import '../../logic/bloc/lokomotif/lokomotif_state.dart';
import '../widgets/lokomotif_card.dart';
import '../pages/lokomotif_form_page.dart';
import '../widgets/logout_dialog.dart';

class LokomotifListPage extends StatefulWidget {
  const LokomotifListPage({super.key});

  @override
  State<LokomotifListPage> createState() => _LokomotifListPageState();
}

class _LokomotifListPageState extends State<LokomotifListPage> {
  int _currentPage = 1;
  int _limit = 10;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchData() {
    context.read<LokomotifBloc>().add(
          LokomotifFetchRequested(
              page: _currentPage, limit: _limit, search: _searchController.text),
        );
  }

  void _showFormSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LokomotifFormPage(),
      ),
    ).then((result) {
      if (result == true) {
        CustomSnackbar.showSuccess(context, 'Lokomotif berhasil ditambahkan');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = false;
    bool isLoggedIn = false;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      isLoggedIn = true;
      isAdmin = authState.user?.role?.toLowerCase() == 'admin';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Image.asset('assets/images/RailSensus_Logo.png', height: 32),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF153D77), size: 20),
              onPressed: () {
                LogoutDialog.show(context);
              },
            ),
          )
        ],
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFFF9428),
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
              onPressed: _showFormSheet,
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Sarana Lokomotif',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF153D77),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari CC 206, depot, livery...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) {
                  setState(() => _currentPage = 1);
                  _fetchData();
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // List and Pagination
          Expanded(
            child: BlocConsumer<LokomotifBloc, LokomotifState>(
              listener: (context, state) {
                if (state is LokomotifActionSuccess) {
                  _fetchData();
                  if (ModalRoute.of(context)?.isCurrent == true) {
                    CustomSnackbar.showSuccess(context, state.message);
                  }
                } else if (state is LokomotifError) {
                  if (ModalRoute.of(context)?.isCurrent == true) {
                    CustomSnackbar.showError(context, state.message);
                  }
                }
              },
              builder: (context, state) {
                if (state is LokomotifLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF153D77)));
                }

                if (state is LokomotifLoaded) {
                  if (state.lokomotifList.isEmpty) {
                    return const Center(child: Text('Data tidak ditemukan'));
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return LokomotifCard(
                                lokomotif: state.lokomotifList[index],
                                isAdmin: isAdmin,
                                isLoggedIn: isLoggedIn,
                              );
                            },
                            childCount: state.lokomotifList.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildPagination(state),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80), // Padding for FAB
                      )
                    ],
                  );
                }

                if (state is LokomotifError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: ${state.message}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                return Center(child: Text('Unrecognized state: ${state.runtimeType}'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(LokomotifLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Items Per Page Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Item per halaman: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              PopupMenuButton<int>(
                initialValue: _limit,
                tooltip: 'Pilih jumlah item',
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                elevation: 4,
                position: PopupMenuPosition.under,
                onSelected: (int newValue) {
                  setState(() {
                    _limit = newValue;
                    _currentPage = 1;
                  });
                  _fetchData();
                },
                itemBuilder: (context) => [5, 10, 20].map((value) => PopupMenuItem<int>(
                  value: value,
                  child: Text(value.toString(), style: const TextStyle(color: Color(0xFF153D77), fontWeight: FontWeight.bold)),
                )).toList(),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_limit.toString(), style: const TextStyle(color: Color(0xFF153D77), fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Pagination Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageButton(
                icon: Icons.chevron_left,
                onTap: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _fetchData();
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              
              // Only showing simple 1, 2 for now, can be expanded for dynamic windows
              for (int i = 1; i <= state.totalPages; i++) ...[
                _buildPageNumberButton(i, i == _currentPage),
                const SizedBox(width: 8),
              ],
              
              _buildPageButton(
                icon: Icons.chevron_right,
                onTap: _currentPage < state.totalPages
                    ? () {
                        setState(() => _currentPage++);
                        _fetchData();
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Halaman $_currentPage dari ${state.totalPages} (${state.totalItems} total)',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget _buildPageButton({required IconData icon, VoidCallback? onTap}) {
    bool isDisabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isDisabled ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, color: isDisabled ? const Color(0xFFCBD5E1) : const Color(0xFF64748B), size: 20),
      ),
    );
  }

  Widget _buildPageNumberButton(int page, bool isActive) {
    return InkWell(
      onTap: !isActive
          ? () {
              setState(() => _currentPage = page);
              _fetchData();
            }
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF153D77) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? const Color(0xFF153D77) : const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
