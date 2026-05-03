import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/admission_response.dart';
import '../../../data/models/user_response.dart';
import '../../../data/repositories/user_repository.dart';
import '../../viewmodels/admission_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/glass_container.dart';

class ServiceNewAdmissionsView extends StatefulWidget {
  const ServiceNewAdmissionsView({super.key});

  @override
  State<ServiceNewAdmissionsView> createState() =>
      _ServiceNewAdmissionsViewState();
}

class _ServiceNewAdmissionsViewState extends State<ServiceNewAdmissionsView> {
  @override
  void initState() {
    super.initState();
    // Cargamos los ingresos al inicializar la vista.
    // Asumimos que el jefe de servicio tiene su ID en el LoginViewModel.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorId = context.read<LoginViewModel>().userId;
      if (doctorId != null) {
        context.read<AdmissionViewModel>().getUserAdmissions(doctorId);
      }
    });
  }

  void _openDoctorAssignmentDialog(
    BuildContext context,
    AdmissionResponse admission,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      builder: (ctx) =>
          _DoctorAssignmentDialog(admission: admission, parentCtx: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdmissionViewModel>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nuevos ingresos",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Listado de nuevos ingresos en tu servicio. Pulsa el botón de edición para reasignar a un médico",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GlassContainer(
              blur: 15,
              opacity: 0.25,
              borderRadius: BorderRadius.circular(20),
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                  ? Center(
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : vm.admissions.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay nuevos ingresos registrados",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : MediaQuery.of(context).size.width < 900
                  ? _buildMobileCards(context, vm)
                  : _buildDesktopTable(context, vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, AdmissionViewModel vm) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.resolveWith(
              (states) => Colors.white.withValues(alpha: 0.4),
            ),
            dataRowColor: WidgetStateProperty.resolveWith(
              (states) => Colors.transparent,
            ),
            columnSpacing: 40,
            columns: const [
              DataColumn(label: Text('')),
              DataColumn(
                label: Text(
                  'Fecha de Ingreso',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Paciente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Diagnóstico',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Habitación',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: vm.admissions.map((admission) {
              final createdAt = admission.createdAt;
              final dateStr =
                  "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}";

              return DataRow(
                cells: [
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      tooltip: "Reasignar médico",
                      onPressed: () =>
                          _openDoctorAssignmentDialog(context, admission),
                    ),
                  ),
                  DataCell(
                    Text(
                      dateStr,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  DataCell(
                    Text(
                      "${admission.patient.name} ${admission.patient.surname}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 250,
                      child: Text(
                        admission.principalDiagnosis ?? "Sin diagnóstico",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      admission.roomNumber?.toString() ?? "Pendiente",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context, AdmissionViewModel vm) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.admissions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final admission = vm.admissions[index];
        final createdAt = admission.createdAt;
        final dateStr =
            "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}";

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${admission.patient.name} ${admission.patient.surname}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GlassContainer(
                    blur: 10,
                    opacity: 0.2,
                    borderRadius: BorderRadius.circular(50),
                    child: Tooltip(
                      message: "Editar médico asignado",
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          splashColor: AppTheme.primaryBlue.withValues(
                            alpha: 0.2,
                          ),
                          highlightColor: Colors.transparent,
                          onTap: () =>
                              _openDoctorAssignmentDialog(context, admission),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.05,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Fecha: $dateStr",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.door_front_door_outlined,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Habitación: ${admission.roomNumber ?? 'Pendiente'}",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Diagnóstico:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                admission.principalDiagnosis ?? "Sin diagnóstico registrado.",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DoctorAssignmentDialog extends StatefulWidget {
  final AdmissionResponse admission;
  final BuildContext parentCtx;

  const _DoctorAssignmentDialog({
    required this.admission,
    required this.parentCtx,
  });

  @override
  State<_DoctorAssignmentDialog> createState() =>
      _DoctorAssignmentDialogState();
}

class _DoctorAssignmentDialogState extends State<_DoctorAssignmentDialog> {
  String? _selectedDoctorId;
  Timer? _debouncer;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _debouncer?.cancel();
    super.dispose();
  }

  void _assignDoctor() async {
    if (_selectedDoctorId == null) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.05),
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 28,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Debes seleccionar un médico al que asignar este ingreso",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gradientStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Aceptar"),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final vm = widget.parentCtx.read<AdmissionViewModel>();
    final success = await vm.assignDoctor(
      widget.admission.admissionId,
      _selectedDoctorId!,
      widget.admission.patient,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (!context.mounted) return;
    Navigator.pop(context);

    if (!widget.parentCtx.mounted) return;
    showDialog(
      context: widget.parentCtx,
      barrierColor: Colors.black.withValues(alpha: 0.05),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                size: 28,
                color: success ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                success
                    ? "Médico reasignado exitosamente"
                    : (vm.errorMessage ?? "Error al reasignar médico"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Aceptar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        blur: 20,
        opacity: 0.2,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.assignment_ind_rounded,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Reasignar Médico",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Paciente: ${widget.admission.patient.name} ${widget.admission.patient.surname}",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Autocomplete<UserResponse>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  final query = textEditingValue.text.trim();
                  if (query.length < 3) {
                    return const Iterable<UserResponse>.empty();
                  }

                  final completer = Completer<Iterable<UserResponse>>();

                  if (_debouncer?.isActive ?? false) {
                    _debouncer!.cancel();
                  }
                  _debouncer = Timer(
                    const Duration(milliseconds: 500),
                    () async {
                      try {
                        final repo = context.read<UserRepository>();
                        final results = await repo.searchBySurname(
                          query,
                          page: 0,
                          size: 10,
                        );
                        if (results.isEmpty) {
                          completer.complete([
                            UserResponse(
                              id: "NO_RESULTS",
                              name: "",
                              surname: "No hay resultados",
                              email: "",
                              role: "",
                            ),
                          ]);
                        } else {
                          completer.complete(results);
                        }
                      } catch (e) {
                        completer.complete([
                          UserResponse(
                            id: "NO_RESULTS",
                            name: "",
                            surname: "Error de conexión",
                            email: "",
                            role: "",
                          ),
                        ]);
                      }
                    },
                  );

                  return completer.future;
                },
                displayStringForOption: (UserResponse option) =>
                    option.id == "NO_RESULTS"
                    ? option.surname
                    : "${option.surname}, ${option.name}",
                onSelected: (UserResponse selection) {
                  if (selection.id == "NO_RESULTS") return;
                  setState(() {
                    _selectedDoctorId = selection.id;
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: "Buscar médico por apellido...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);

                            if (option.id == "NO_RESULTS") {
                              return ListTile(
                                leading: const Icon(
                                  Icons.search_off_rounded,
                                  color: Colors.grey,
                                ),
                                title: Text(
                                  option.surname,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              );
                            }

                            return ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: AppTheme.primaryBlue,
                              ),
                              title: Text("${option.surname}, ${option.name}"),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.gradientStart,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _assignDoctor,
                          child: const Text("Asignar"),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
