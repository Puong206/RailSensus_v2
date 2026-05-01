import '../widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/bloc/sensus/sensus_bloc.dart';
import '../../logic/bloc/sensus/sensus_event.dart';
import '../../logic/bloc/sensus/sensus_state.dart';
import '../widgets/sensus_card.dart';
import '../widgets/logout_dialog.dart';

class SensusFeedPage extends StatefulWidget {
  const SensusFeedPage({super.key});

  @override
  State<SensusFeedPage> createState() => _SensusFeedPageState();
}

class _SensusFeedPageState extends State<SensusFeedPage> {
  int _currentPage = 1;
  int _limit = 5; // Default 5 for sensus feed since cards are larger
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
    context.read<SensusBloc>().add(
          SensusFetchRequested(
              page: _currentPage, limit: _limit, search: _searchController.text),
        );
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
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
              icon:
                  const Icon(Icons.logout, color: Color(0xFF153D77), size: 20),
              onPressed: () {
                LogoutDialog.show(context);
              },
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Sensus KA',
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari nomor kereta...',
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
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF153D77),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF153D77).withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () {}, // Filter could be added here later
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: BlocConsumer<SensusBloc, SensusState>(
              listener: (context, state) {
                if (state is SensusError) {
                  CustomSnackbar.showError(context, 'Gagal memuat data: ${state.message}');
                }
              },
              builder: (context, state) {
                if (state is SensusInitial ||
                    (state is SensusLoading && state.isFirstFetch)) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF153D77)));
                }

                final bloc = context.read<SensusBloc>();
                
                final sensusList = state is SensusLoaded
                    ? state.sensus
                    : bloc.currentFeed;

                if (state is SensusError && sensusList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}',
                            style: const TextStyle(color: Colors.red)),
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('Coba Lagi'),
                        )
                      ],
                    ),
                  );
                }

                if (sensusList.isEmpty && state is SensusLoaded) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9428).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.train_outlined, size: 64, color: Color(0xFFFF9428)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Belum Ada Data Sensus',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF153D77)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Jadilah yang pertama menambahkan\ndata sensus kereta api!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF94A3B8), height: 1.5),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF153D77),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SensusCard(
                                  sensus: sensusList[index], 
                                  width: double.infinity,
                                  margin: EdgeInsets.zero,
                                ),
                              );
                            },
                            childCount: sensusList.length,
                          ),
                        ),
                      ),
                      if (state is SensusLoaded)
                        SliverToBoxAdapter(
                          child: _buildPagination(state),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80), // Space for FAB
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF9428),
        shape: const CircleBorder(),
        onPressed: () => context.push('/sensus/form'),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildPagination(SensusLoaded state) {
    if (state.totalItems == 0) return const SizedBox.shrink();
    
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
              
              // Simple page numbers
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
