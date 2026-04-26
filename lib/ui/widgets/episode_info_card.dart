import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/episode_response.dart';
import '../viewmodels/episode_viewmodel.dart';
import '../widgets/braden_calculator_dialog.dart';
import '../widgets/cam_calculator_dialog.dart';
import '../widgets/chads2_calculator_dialog.dart';
import 'glass_container.dart';
import 'scale_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de información principal del episodio
// ─────────────────────────────────────────────────────────────────────────────
class EpisodeInfoCard extends StatelessWidget {
  final EpisodeResponse episode;

  final bool canEdit;

  final void Function(EpisodeResponse updated)? onEpisodeUpdated;

  const EpisodeInfoCard({
    super.key,
    required this.episode,
    this.canEdit = false,
    this.onEpisodeUpdated,
  });

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.05),
      builder: (_) => _EpisodeEditSheet(
        episode: episode,
        onEpisodeUpdated: onEpisodeUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

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
                  radius: isMobile ? 24 : 32,
                  backgroundColor: const Color(
                    0xFF4C56AF,
                  ).withValues(alpha: 0.15),
                  child: Icon(
                    Icons.medical_information_rounded,
                    size: isMobile ? 28 : 36,
                    color: const Color(0xFF4C56AF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Registro médico",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18 : 20,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Creado por: ${episode.createdByName ?? "Dr. ${episode.createdBy}"}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today_rounded,
                            label: _formatDate(episode.createdAt),
                          ),
                          _InfoChip(
                            icon: Icons.access_time_rounded,
                            label: _formatTime(episode.createdAt),
                          ),
                          _InfoChip(
                            icon: Icons.calendar_today_rounded,
                            label:
                                "Última modificación: ${_formatDate(episode.lastModifiedAt!)}",
                          ),
                          _InfoChip(
                            icon: Icons.access_time_rounded,
                            label: _formatTime(episode.lastModifiedAt!),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (canEdit)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ScaleButton(
                      onTap: () => _openEditSheet(context),
                      child: GlassContainer(
                        blur: 10,
                        opacity: 0.2,
                        borderRadius: BorderRadius.circular(50),
                        child: Tooltip(
                          message: "Editar episodio",
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              splashColor: AppTheme.primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                              highlightColor: Colors.transparent,
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
                                  size: 24,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
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

            _ScoresGrid(isMobile: isMobile, episode: episode),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet de edición del episodio
// ─────────────────────────────────────────────────────────────────────────────
class _EpisodeEditSheet extends StatefulWidget {
  final EpisodeResponse episode;
  final void Function(EpisodeResponse updated)? onEpisodeUpdated;

  const _EpisodeEditSheet({required this.episode, this.onEpisodeUpdated});

  @override
  State<_EpisodeEditSheet> createState() => _EpisodeEditSheetState();
}

class _EpisodeEditSheetState extends State<_EpisodeEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clinicalProgressController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _bradenScoreController;
  late final TextEditingController _chads2ScoreController;
  bool? _camScore;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final ep = widget.episode;
    _clinicalProgressController = TextEditingController(
      text: ep.clinicalProgress,
    );
    _diagnosisController = TextEditingController(text: ep.diagnosis);
    _bradenScoreController = TextEditingController(
      text: ep.bradenScore?.toString() ?? '',
    );
    _chads2ScoreController = TextEditingController(
      text: ep.chads2Score?.toString() ?? '',
    );
    _camScore = ep.camScore;
  }

  @override
  void dispose() {
    _clinicalProgressController.dispose();
    _diagnosisController.dispose();
    _bradenScoreController.dispose();
    _chads2ScoreController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final viewModel = context.read<EpisodeViewModel>();
    final success = await viewModel.updateEpisode(
      episodeId: widget.episode.episodeId,
      clinicalProgress: _clinicalProgressController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      bradenScore: int.tryParse(_bradenScoreController.text),
      chads2Score: int.tryParse(_chads2ScoreController.text),
      camScore: _camScore,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Construimos el EpisodeResponse actualizado localmente para evitar
      // un GET extra, usando los valores que el usuario acaba de enviar.
      final updated = EpisodeResponse(
        episodeId: widget.episode.episodeId,
        admissionId: widget.episode.admissionId,
        doctorId: widget.episode.doctorId,
        clinicalProgress: _clinicalProgressController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        bradenScore: int.tryParse(_bradenScoreController.text),
        chads2Score: int.tryParse(_chads2ScoreController.text),
        camScore: _camScore,
        createdAt: widget.episode.createdAt,
        createdBy: widget.episode.createdBy,
        createdByName: widget.episode.createdByName,
        lastModifiedAt: DateTime.now(),
        lastModifiedBy: widget.episode.createdBy,
      );

      widget.onEpisodeUpdated?.call(updated);
      Navigator.of(context).pop();
      _showFeedback(context, success: true);
    } else {
      _showFeedback(context, success: false, message: viewModel.errorMessage);
    }
  }

  void _showFeedback(
    BuildContext context, {
    required bool success,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.05),
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
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
                    color: success ? const Color(0xFF4CAF50) : Colors.redAccent,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    success ? "¡Actualizado!" : "Error",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    success
                        ? "El episodio se ha actualizado correctamente."
                        : (message ?? "Error desconocido"),
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
                      onPressed: () => Navigator.of(dialogContext).pop(),
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

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    "Editar Episodio",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: _clinicalProgressController,
                    label: "Progreso clínico*",
                    hint: "Describa la evolución del paciente...",
                    maxLines: 4,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: _diagnosisController,
                    label: "Diagnóstico*",
                    hint: "Indique el diagnóstico...",
                    maxLines: 2,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: _bradenScoreController,
                          label: "Braden Score",
                          hint: "Ej. 15",
                          keyboardType: TextInputType.number,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calculate_rounded,
                              color: AppTheme.primaryBlue,
                            ),
                            tooltip: "Calcular Braden",
                            onPressed: () async {
                              final int? result = await showDialog<int>(
                                context: context,
                                barrierColor: Colors.black.withValues(
                                  alpha: 0.05,
                                ),
                                builder: (_) => const BradenCalculatorDialog(),
                              );
                              if (result != null) {
                                _bradenScoreController.text = result.toString();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          controller: _chads2ScoreController,
                          label: "CHADS2 Score",
                          hint: "Ej. 2",
                          keyboardType: TextInputType.number,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calculate_rounded,
                              color: AppTheme.primaryBlue,
                            ),
                            tooltip: "Calcular CHADS2",
                            onPressed: () async {
                              final int? result = await showDialog<int>(
                                context: context,
                                barrierColor: Colors.black.withValues(
                                  alpha: 0.05,
                                ),
                                builder: (_) => const Chads2CalculatorDialog(),
                              );
                              if (result != null) {
                                _chads2ScoreController.text = result.toString();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "CAM Score",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<bool?>(
                              value: _camScore,
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              hint: const Text("Seleccione resultado CAM"),
                              items: const [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text("No evaluado"),
                                ),
                                DropdownMenuItem(
                                  value: true,
                                  child: Text("Positivo"),
                                ),
                                DropdownMenuItem(
                                  value: false,
                                  child: Text("Negativo"),
                                ),
                              ],
                              onChanged: (v) => setState(() => _camScore = v),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.calculate_rounded,
                          color: AppTheme.primaryBlue,
                          size: 32,
                        ),
                        tooltip: "Calcular CAM",
                        onPressed: () async {
                          final bool? result = await showDialog<bool>(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.05),
                            builder: (_) => const CamCalculatorDialog(),
                          );
                          if (result != null) {
                            setState(() => _camScore = result);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gradientStart,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Guardar cambios",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

  Widget _buildField({
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

// ─────────────────────────────────────────────────────────────────────────────
// Grid de escalas clínicas
// ─────────────────────────────────────────────────────────────────────────────
class _ScoresGrid extends StatelessWidget {
  final bool isMobile;
  final EpisodeResponse episode;

  const _ScoresGrid({required this.isMobile, required this.episode});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _DataTile(
          icon: Icons.health_and_safety_outlined,
          label: "Escala Braden",
          value: "${episode.bradenScore ?? "No realizado"}",
        ),
        if (episode.camScore != null)
          _DataTile(
            icon: Icons.psychology_outlined,
            label: "CAM",
            value: episode.camScore == true ? "Positivo" : "Negativo",
          )
        else
          _DataTile(
            icon: Icons.psychology_outlined,
            label: "CAM",
            value: "No realizado",
          ),
        _DataTile(
          icon: Icons.favorite_border_rounded,
          label: "CHADS2",
          value: "${episode.chads2Score ?? "No realizado"}",
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile compacto para escalas y datos numéricos
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Chip informativo
// ─────────────────────────────────────────────────────────────────────────────
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
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
