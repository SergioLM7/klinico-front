import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/admission_response.dart';
import '../../../data/models/episode_response.dart';
import '../../../data/repositories/admission_repository.dart';
import '../../../data/repositories/episode_repository.dart';
import '../../viewmodels/admission_viewmodel.dart';
import '../../viewmodels/episode_viewmodel.dart';
import '../episodes/episode_detail_view.dart';
import '../episodes/episode_form_view.dart';
import '../../widgets/barthel_calculator_dialog.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_scaffold.dart';

/// Vista de detalle de un ingreso.
class AdmissionDetailView extends StatefulWidget {
  final AdmissionResponse admission;

  const AdmissionDetailView({super.key, required this.admission});

  @override
  State<AdmissionDetailView> createState() => _AdmissionDetailViewState();
}

class _AdmissionDetailViewState extends State<AdmissionDetailView> {
  late AdmissionResponse _admission;

  @override
  void initState() {
    super.initState();
    _admission = widget.admission;
  }

  void _onAdmissionUpdated(AdmissionResponse updated) {
    setState(() {
      _admission = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) =>
              EpisodeViewModel(repository: ctx.read<EpisodeRepository>())
                ..loadEpisodes(_admission.admissionId),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              AdmissionViewModel(repository: ctx.read<AdmissionRepository>()),
        ),
      ],
      child: _AdmissionDetailContent(
        admission: _admission,
        onAdmissionUpdated: _onAdmissionUpdated,
      ),
    );
  }
}

class _AdmissionDetailContent extends StatelessWidget {
  final AdmissionResponse admission;
  final Function(AdmissionResponse) onAdmissionUpdated;

  const _AdmissionDetailContent({
    required this.admission,
    required this.onAdmissionUpdated,
  });

  void _openUpdateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.05),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdmissionViewModel>(),
        child: _AdmissionUpdateSheet(
          admission: admission,
          onAdmissionUpdated: onAdmissionUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return GradientScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + (isMobile ? 16.0 : 32.0),
          left: isMobile ? 16.0 : 32.0,
          right: isMobile ? 16.0 : 32.0,
          bottom: isMobile ? 24.0 : 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header with Back Button
            Row(
              children: [
                GlassContainer(
                  blur: 10,
                  opacity: 0.2,
                  borderRadius: BorderRadius.circular(50),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      splashColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      highlightColor: AppTheme.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Detalle de ingreso",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _PatientInfoCard(
              admission: admission,
              onEdit: () => _openUpdateSheet(context),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  "Episodios clínicos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                GlassContainer(
                  blur: 10,
                  opacity: 0.2,
                  borderRadius: BorderRadius.circular(50),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      splashColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      highlightColor: AppTheme.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EpisodeFormView(
                              admissionId: admission.admissionId,
                            ),
                          ),
                        );
                        if (result == true && context.mounted) {
                          context.read<EpisodeViewModel>().loadEpisodes(
                            admission.admissionId,
                          );
                        }
                      },
                      child: const Tooltip(
                        message: "Nuevo episodio",
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.add_rounded,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _EpisodeList(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bloque de datos principales del ingreso
// ─────────────────────────────────────────────────────────────────────────────
class _PatientInfoCard extends StatelessWidget {
  final AdmissionResponse admission;
  final VoidCallback onEdit;

  const _PatientInfoCard({required this.admission, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final patient = admission.patient;
    final bool isFemale = patient.sex.toUpperCase() == 'F';

    return GlassContainer(
      blur: 15,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isMobile ? 28 : 36,
                  backgroundColor: (isFemale ? Colors.pink : Colors.blue)
                      .withValues(alpha: 0.2),
                  child: Icon(
                    isFemale ? Icons.face_3_rounded : Icons.face_rounded,
                    size: isMobile ? 32 : 40,
                    color: isFemale ? Colors.pink : Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${patient.surname}, ${patient.name}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18 : 22,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _SpecialChip(
                            (admission.allergies != null &&
                                    admission.allergies!.trim().isNotEmpty &&
                                    admission.allergies!.toLowerCase() !=
                                        "no conocidas")
                                ? "Alergias: ${admission.allergies!}"
                                : "Sin alergias conocidas",
                            Colors.redAccent,
                          ),
                          _SpecialChip(
                            admission.principalDiagnosis ?? "Sin diagnóstico",
                            AppTheme.primaryBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _InfoChip(
                            icon: Icons.door_front_door_outlined,
                            label: admission.roomNumber != null
                                ? "Hab. ${admission.roomNumber}"
                                : "Pend. habitación",
                          ),
                          _InfoChip(
                            icon: Icons.fact_check_outlined,
                            label:
                                "Nº HC: ${patient.patientId.length > 8 ? patient.patientId.substring(0, 8) : patient.patientId}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Botón Editar Ingreso
                GlassContainer(
                  blur: 10,
                  opacity: 0.2,
                  borderRadius: BorderRadius.circular(50),
                  child: Tooltip(
                    message: "Editar ingreso",
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        splashColor: AppTheme.primaryBlue.withValues(
                          alpha: 0.2,
                        ),
                        highlightColor: Colors.transparent,
                        onTap: onEdit,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            semanticLabel: "Editar ingreso",
                            size: 24,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.black12),
            const SizedBox(height: 16),
            _InfoGrid(isMobile: isMobile, admission: admission),
            if (admission.medicalHistory != null) ...[
              const SizedBox(height: 16),
              _LongTextField(
                label: "Antecedentes clínicos",
                value: admission.medicalHistory!,
              ),
            ],
            if (admission.chronicTreatment != null) ...[
              const SizedBox(height: 12),
              _LongTextField(
                label: "Tratamiento crónico",
                value: admission.chronicTreatment!,
              ),
            ],
            if (admission.allergies != null) ...[
              const SizedBox(height: 12),
              _LongTextField(
                label: "Alergias",
                value: admission.allergies!,
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet: Actualización de Ingreso
// ─────────────────────────────────────────────────────────────────────────────
class _AdmissionUpdateSheet extends StatefulWidget {
  final AdmissionResponse admission;
  final Function(AdmissionResponse) onAdmissionUpdated;

  const _AdmissionUpdateSheet({
    required this.admission,
    required this.onAdmissionUpdated,
  });

  @override
  State<_AdmissionUpdateSheet> createState() => _AdmissionUpdateSheetState();
}

class _AdmissionUpdateSheetState extends State<_AdmissionUpdateSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _diagnosisController;
  late TextEditingController _historyController;
  late TextEditingController _allergiesController;
  late TextEditingController _treatmentController;
  late TextEditingController _barthelController;

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController(
      text: widget.admission.principalDiagnosis,
    );
    _historyController = TextEditingController(
      text: widget.admission.medicalHistory,
    );
    _allergiesController = TextEditingController(
      text: widget.admission.allergies,
    );
    _treatmentController = TextEditingController(
      text: widget.admission.chronicTreatment,
    );
    _barthelController = TextEditingController(
      text: widget.admission.basalBarthel?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _historyController.dispose();
    _allergiesController.dispose();
    _treatmentController.dispose();
    _barthelController.dispose();
    super.dispose();
  }

  void _showFeedback(bool success, String message, {VoidCallback? onConfirm}) {
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
              Icon(
                success ? Icons.check_circle : Icons.error_outline_rounded,
                size: 28,
                color: success ? Colors.green : Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
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
                    Navigator.of(ctx).pop();
                    if (onConfirm != null) onConfirm();
                  },
                  child: const Text("Aceptar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdmissionViewModel>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Gestionar Ingreso/Alta",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    _diagnosisController,
                    "Diagnóstico principal*",
                    2,
                  ),
                  const SizedBox(height: 12),
                  _buildField(_historyController, "Antecedentes médicos*", 3),
                  const SizedBox(height: 12),
                  _buildField(_allergiesController, "Alergias", 1),
                  const SizedBox(height: 12),
                  _buildField(_treatmentController, "Tratamiento crónico", 2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          _barthelController,
                          "Barthel basal",
                          1,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calculate,
                          color: AppTheme.primaryBlue,
                        ),
                        onPressed: () async {
                          final res = await showDialog<int>(
                            context: context,
                            barrierColor: Colors.transparent,
                            builder: (_) => const BarthelCalculatorDialog(),
                          );
                          if (res != null) {
                            _barthelController.text = res.toString();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (vm.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gradientStart,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              final updated = await vm.clinicalUpdate(
                                admissionId: widget.admission.admissionId,
                                principalDiagnosis: _diagnosisController.text,
                                medicalHistory: _historyController.text,
                                patient: widget.admission.patient,
                                allergies: _allergiesController.text,
                                chronicTreatment: _treatmentController.text,
                                basalBarthel: int.tryParse(
                                  _barthelController.text,
                                ),
                              );

                              if (mounted) {
                                if (updated != null) {
                                  widget.onAdmissionUpdated(updated);
                                  Navigator.of(
                                    context,
                                  ).pop(); // Cerramos el sheet
                                  _showFeedback(true, "Ingreso actualizado");
                                } else {
                                  _showFeedback(
                                    false,
                                    vm.errorMessage ??
                                        "Error al actualizar el ingreso",
                                  );
                                }
                              }
                            },
                            child: const Text(
                              "GUARDAR CAMBIOS",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                barrierColor: Colors.black.withValues(
                                  alpha: 0.1,
                                ),
                                builder: (ctx) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: GlassContainer(
                                    blur: 20,
                                    opacity: 0.2,
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.redAccent,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Firmar alta",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "¿Estás seguro de que quieres dar el alta a este paciente? Esta acción no se puede deshacer",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text(
                                                  "Cancelar",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme
                                                      .gradientStart
                                                      .withValues(alpha: 0.8),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text("Aceptar"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              if (confirm == true && mounted) {
                                final success = await vm.dischargeAdmission(
                                  widget.admission.admissionId,
                                );
                                if (mounted) {
                                  if (success) {
                                    final navigator = Navigator.of(context);
                                    navigator.pop(); // Cierra sheet
                                    _showFeedback(
                                      true,
                                      "Alta firmada con éxito",
                                      onConfirm: () {
                                        navigator.pop(); // Vuelve al dashboard
                                      },
                                    );
                                  } else {
                                    _showFeedback(
                                      false,
                                      vm.errorMessage ??
                                          "Error al firmar el alta",
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text(
                              "FIRMAR ALTA",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    int maxLines, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (v) => (v == null || v.isEmpty) && label.contains('*')
              ? "Campo requerido"
              : null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resto de los widgets (Grid, DataTile, etc.)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  final bool isMobile;
  final AdmissionResponse admission;

  const _InfoGrid({required this.isMobile, required this.admission});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _DataTile(
          icon: Icons.cake_outlined,
          label: "Edad",
          value: "${admission.patient.age} años",
        ),
        _DataTile(
          icon: Icons.wc_rounded,
          label: "Sexo",
          value: admission.patient.sex.toUpperCase() == 'F'
              ? "Femenino"
              : "Masculino",
        ),
        if (admission.basalBarthel != null)
          _DataTile(
            icon: Icons.accessibility_new_rounded,
            label: "Barthel basal",
            value: "${admission.basalBarthel}",
          ),
        if (admission.hospitalizationLength != null)
          _DataTile(
            icon: Icons.hotel_rounded,
            label: "Días ingresado",
            value: "${admission.hospitalizationLength}",
          ),
        _DataTile(
          icon: Icons.calendar_today_rounded,
          label: "Ingresado el",
          value: _formatDate(admission.createdAt),
        ),
        if (admission.dischargeDate != null)
          _DataTile(
            icon: Icons.exit_to_app_rounded,
            label: "Alta el",
            value: _formatDate(admission.dischargeDate!),
          ),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
}

class _DataTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4C56AF)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LongTextField extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _LongTextField({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}

class _SpecialChip extends StatelessWidget {
  final Color color;
  final String label;
  const _SpecialChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeList extends StatelessWidget {
  const _EpisodeList();

  @override
  Widget build(BuildContext context) {
    return Consumer<EpisodeViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.errorMessage != null) {
          return Center(
            child: Text(
              vm.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (vm.episodes.isEmpty) {
          return const Center(
            child: Text(
              "No hay episodios registrados.",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: vm.episodes
              .map((episode) => _EpisodeCard(episode: episode))
              .toList(),
        );
      },
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final EpisodeResponse episode;
  const _EpisodeCard({required this.episode});

  @override
  Widget build(BuildContext context) {
    final dt = episode.createdAt;
    final dateStr =
        "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    final timeStr =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EpisodeDetailView(episode: episode),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C56AF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    size: 20,
                    color: Color(0xFF4C56AF),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Evolución",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "$dateStr · $timeStr",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
