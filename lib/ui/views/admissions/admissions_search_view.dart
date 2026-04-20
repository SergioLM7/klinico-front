import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/admission_response.dart';
import '../../../data/repositories/admission_repository.dart';
import '../../widgets/admission_card.dart';
import '../../widgets/glass_container.dart';

class AdmissionsSearchView extends StatefulWidget {
  const AdmissionsSearchView({super.key});

  @override
  State<AdmissionsSearchView> createState() => _AdmissionsSearchViewState();
}

class _AdmissionsSearchViewState extends State<AdmissionsSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AdmissionResponse> _admissions = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String _currentQuery = '';
  Timer? _debouncer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim() != _currentQuery) {
        setState(() {
          _currentQuery = query.trim();
          _currentPage = 0;
          _hasMore = true;
          _admissions = [];
        });
        if (_currentQuery.isNotEmpty) {
          _loadMore();
        }
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore || _currentQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = context.read<AdmissionRepository>();
      final paginatedResult = await repo.searchBySurname(
        surname: _currentQuery,
        page: _currentPage,
      );

      final newItems = paginatedResult.content.cast<AdmissionResponse>();

      setState(() {
        _currentPage++;
        _isLoading = false;
        _hasMore = !paginatedResult.isLast;
        _admissions.addAll(newItems);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al buscar pacientes: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Buscador Glassmorphism
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText:
                    "Buscar ingresos del servicio por apellidos del paciente...",
                hintStyle: TextStyle(color: Colors.black54),
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryBlue),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // Lista de Resultados
        Expanded(
          child: _currentQuery.isEmpty
              ? const Center(
                  child: Text(
                    "Introduce los apellidos de un paciente para buscar",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                )
              : _admissions.isEmpty && !_isLoading
              ? const Center(
                  child: Text(
                    "No se han encontrado ingresos en tu servicio con ese criterio de búsqueda",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _admissions.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _admissions.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final admission = _admissions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: AdmissionCard(admission: admission),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
