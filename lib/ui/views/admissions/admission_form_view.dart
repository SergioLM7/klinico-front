import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/patient_response.dart';
import '../../../data/models/service_response.dart';
import '../../viewmodels/admission_viewmodel.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../data/repositories/service_repository.dart';
import '../../widgets/barthel_calculator_dialog.dart';
import '../../widgets/glass_container.dart';

class AdmissionFormView extends StatefulWidget {
  const AdmissionFormView({super.key});

  @override
  State<AdmissionFormView> createState() => _AdmissionFormViewState();
}

class _AdmissionFormViewState extends State<AdmissionFormView> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPatientId;
  Timer? _debouncer;
  Key _patientAutocompleteKey = UniqueKey();

  String? _selectedServiceId;
  Timer? _debouncerService;
  Key _serviceAutocompleteKey = UniqueKey();

  final ScrollController _scrollController = ScrollController();

  final _principalDiagnosisController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  final _allergiesController = TextEditingController();
  final _chronicTreatmentController = TextEditingController();
  final _basalBarthelController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _debouncer?.cancel();
    _debouncerService?.cancel();
    _principalDiagnosisController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _chronicTreatmentController.dispose();
    _basalBarthelController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null || _selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedPatientId == null
                ? "Debes seleccionar un paciente de la lista"
                : "Debes seleccionar un servicio de la lista",
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus(); // Ocultamos el teclado virtual

    setState(() {
      _isLoading = true;
    });

    final viewModel = context.read<AdmissionViewModel>();
    final success = await viewModel.createAdmission(
      patientId: _selectedPatientId!,
      serviceId: _selectedServiceId!,
      principalDiagnosis: _principalDiagnosisController.text,
      medicalHistory: _medicalHistoryController.text,
      allergies: _allergiesController.text,
      chronicTreatment: _chronicTreatmentController.text,
      basalBarthel: int.tryParse(_basalBarthelController.text),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.05),
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      success
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      color: success
                          ? const Color(0xFF4CAF50)
                          : Colors.redAccent,
                      size: 28,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      success ? "¡Excelente!" : "Error",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      success
                          ? "Ingreso creado exitosamente"
                          : (context.read<AdmissionViewModel>().errorMessage ??
                                "Error desconocido"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gradientStart,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el dialog
                          //Limpiamos el formulario
                          if (success) {
                            _formKey.currentState?.reset();
                            _principalDiagnosisController.clear();
                            _medicalHistoryController.clear();
                            _allergiesController.clear();
                            _chronicTreatmentController.clear();
                            _basalBarthelController.clear();
                            setState(() {
                              _selectedPatientId = null;
                              _selectedServiceId = null;
                              _patientAutocompleteKey = UniqueKey();
                              _serviceAutocompleteKey = UniqueKey();
                            });

                            // Hacemos scroll suave hasta arriba del todo
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        },
                        child: const Text(
                          "Aceptar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (isMobile ? 16.0 : 32.0),
        left: isMobile ? 16.0 : 32.0,
        right: isMobile ? 16.0 : 32.0,
        bottom: isMobile ? 24.0 : 32.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Nuevo ingreso",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Rellena los datos a continuación para crear un nuevo ingreso",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(20),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Datos de Identificación",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Paciente*",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Autocomplete<PatientResponse>(
                        key: _patientAutocompleteKey,
                        optionsBuilder: (TextEditingValue textEditingValue) async {
                          final query = textEditingValue.text.trim();
                          if (query.length < 3) {
                            return const Iterable<PatientResponse>.empty();
                          }

                          final completer =
                              Completer<Iterable<PatientResponse>>();

                          if (_debouncer?.isActive ?? false) {
                            _debouncer!.cancel();
                          }
                          _debouncer = Timer(
                            const Duration(milliseconds: 500),
                            () async {
                              try {
                                final repo = context.read<PatientRepository>();
                                final results = await repo.searchBySurname(
                                  query,
                                  page: 0,
                                  size: 10,
                                );
                                if (results.isEmpty) {
                                  completer.complete([
                                    PatientResponse(
                                      patientId: "NO_RESULTS",
                                      name: "",
                                      surname:
                                          "No hay resultados para esta búsqueda",
                                      birthdate: DateTime.now(),
                                      sex: "U",
                                      status: "NONE",
                                    ),
                                  ]);
                                } else {
                                  completer.complete(results);
                                }
                              } catch (e) {
                                completer.complete([
                                  PatientResponse(
                                    patientId: "NO_RESULTS",
                                    name: "",
                                    surname: "Error de conexión",
                                    birthdate: DateTime.now(),
                                    sex: "U",
                                    status: "NONE",
                                  ),
                                ]);
                              }
                            },
                          );

                          return completer.future;
                        },
                        displayStringForOption: (PatientResponse option) =>
                            option.patientId == "NO_RESULTS"
                            ? option.surname
                            : "${option.surname}, ${option.name}",
                        onSelected: (PatientResponse selection) {
                          if (selection.patientId == "NO_RESULTS") return;
                          setState(() {
                            _selectedPatientId = selection.patientId;
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                validator: (value) =>
                                    _selectedPatientId == null ||
                                        value == null ||
                                        value.isEmpty
                                    ? "Debes seleccionar un paciente de la lista"
                                    : null,
                                decoration: InputDecoration(
                                  hintText: "Ej. García",
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.7,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTheme.primaryBlue,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: AppTheme.primaryBlue,
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

                                    if (option.patientId == "NO_RESULTS") {
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
                                      title: Text(
                                        "${option.surname}, ${option.name}",
                                      ),
                                      subtitle: Text(
                                        "ID: ${option.patientId.substring(0, 8)}...",
                                      ),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Servicio asignado*",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Autocomplete<ServiceResponse>(
                        key: _serviceAutocompleteKey,
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                              final query = textEditingValue.text.trim();
                              if (query.length < 3) {
                                return const Iterable<ServiceResponse>.empty();
                              }

                              final completer =
                                  Completer<Iterable<ServiceResponse>>();

                              if (_debouncerService?.isActive ?? false) {
                                _debouncerService!.cancel();
                              }
                              _debouncerService = Timer(
                                const Duration(milliseconds: 500),
                                () async {
                                  try {
                                    final repo = context
                                        .read<ServiceRepository>();
                                    final results = await repo.searchByName(
                                      query,
                                      page: 0,
                                      size: 10,
                                    );
                                    if (results.isEmpty) {
                                      completer.complete([
                                        ServiceResponse(
                                          serviceId: "NO_RESULTS",
                                          name: "Servicio no encontrado",
                                          active: false,
                                        ),
                                      ]);
                                    } else {
                                      completer.complete(results);
                                    }
                                  } catch (e) {
                                    completer.complete([
                                      ServiceResponse(
                                        serviceId: "NO_RESULTS",
                                        name: "Error de conexión",
                                        active: false,
                                      ),
                                    ]);
                                  }
                                },
                              );

                              return completer.future;
                            },
                        displayStringForOption: (ServiceResponse option) =>
                            option.serviceId == "NO_RESULTS"
                            ? option.name
                            : option.name,
                        onSelected: (ServiceResponse selection) {
                          if (selection.serviceId == "NO_RESULTS") return;
                          setState(() {
                            _selectedServiceId = selection.serviceId;
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                validator: (value) =>
                                    _selectedServiceId == null ||
                                        value == null ||
                                        value.isEmpty
                                    ? "Debes seleccionar un servicio de la lista"
                                    : null,
                                decoration: InputDecoration(
                                  hintText: "Ej. Cardiología",
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.7,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppTheme.primaryBlue,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.local_hospital,
                                    color: AppTheme.primaryBlue,
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
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final option = options.elementAt(index);

                                        if (option.serviceId == "NO_RESULTS") {
                                          return ListTile(
                                            leading: const Icon(
                                              Icons.search_off_rounded,
                                              color: Colors.grey,
                                            ),
                                            title: Text(
                                              option.name,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          );
                                        }

                                        return ListTile(
                                          leading: const Icon(
                                            Icons.local_hospital,
                                            color: AppTheme.primaryBlue,
                                          ),
                                          title: Text(option.name),
                                          subtitle: Text(
                                            option.active
                                                ? "Activo"
                                                : "Inactivo",
                                            style: TextStyle(
                                              color: option.active
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
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
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(20),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Información Clínica Principal",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _principalDiagnosisController,
                    label: "Diagnóstico Principal*",
                    hint: "Describa el diagnóstico de ingreso...",
                    maxLines: 2,
                    validator: (value) => value == null || value.isEmpty
                        ? "Debes rellenar este apartado"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _medicalHistoryController,
                    label: "Historial Médico*",
                    hint: "Detalle los antecedentes clínicos...",
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty
                        ? "Debes rellenar este apartado"
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(20),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Información Adicional (Opcional)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _allergiesController,
                    label: "Alergias",
                    hint: "Indique intolerancias o alergias...",
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _chronicTreatmentController,
                    label: "Tratamiento Crónico",
                    hint: "Medicación habitual previa al ingreso...",
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _basalBarthelController,
                    label: "Índice de Barthel Basal",
                    hint: "Rango numérico 0 - 100",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final intVal = int.tryParse(value);
                        if (intVal == null || intVal < 0 || intVal > 100) {
                          return "Debe ser un número entre 0 y 100";
                        }
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calculate_rounded,
                        color: AppTheme.primaryBlue,
                      ),
                      tooltip: "Calcular Escala de Barthel",
                      onPressed: () async {
                        final int? result = await showDialog<int>(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (context) => const BarthelCalculatorDialog(),
                        );
                        if (result != null) {
                          _basalBarthelController.text = result.toString();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gradientStart,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Crear Ingreso",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
